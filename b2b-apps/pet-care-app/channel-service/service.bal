import ballerina/http;
import ballerina/jwt;
import ballerina/mime;
import ballerina/log;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # Get all doctors
    # + return - List of doctors or error
    resource function get doctors(http:Headers headers) returns Doctor[]|error? {

        string|error org = getOrg(headers);
        if org is error {
            return org;
        }

        return getDoctors(org);
    }

    # Create a new doctor
    # + newDoctor - basic doctor details
    # + return - created doctor record or error
    resource function post doctors(http:Headers headers, @http:Payload DoctorItem newDoctor) returns Doctor|http:Created|error? {

        string|error org = getOrg(headers);
        if org is error {
            return org;
        }

        Doctor|error doctor = addDoctor(newDoctor, org);
        return doctor;
    }

    # Get a doctor by ID
    # + doctorId - ID of the doctor
    # + return - Doctor details or not found 
    resource function get doctors/[string doctorId](http:Headers headers) returns Doctor|http:NotFound|error? {

        string|error org = getOrg(headers);
        if org is error {
            return org;
        }

        Doctor|()|error result = getDoctorByIdAndOrg(org, doctorId);
        if result is () {
            return http:NOT_FOUND;
        }
        return result;
    }

    # Update a doctor
    # + doctorId - ID of the doctor
    # + updatedDoctorItem - updated doctor details
    # + return - Doctor details or not found 
    resource function put doctors/[string doctorId](http:Headers headers, @http:Payload DoctorItem updatedDoctorItem) returns Doctor|http:NotFound|error? {

        string|error org = getOrg(headers);
        if org is error {
            return org;
        }

        Doctor|()|error result = updateDoctorById(org, doctorId, updatedDoctorItem);
        if result is () {
            return http:NOT_FOUND;
        }
        return result;
    }

    # Delete a doctor
    # + doctorId - ID of the doctor
    # + return - Ok response or error
    resource function delete doctors/[string doctorId](http:Headers headers) returns http:NoContent|http:NotFound|error? {

        string|error org = getOrg(headers);
        if org is error {
            return org;
        }

        string|()|error result = deleteDoctorById(org, doctorId);
        if result is () {
            return http:NOT_FOUND;
        } else if result is error {
            return result;
        }
        return http:NO_CONTENT;
    }

    # Update the thumbnail image of a doctor
    # + doctorId - ID of the doctor
    # + return - Ok response or error
    resource function put doctors/[string doctorId]/thumbnail(http:Request request, http:Headers headers)
    returns http:Ok|http:NotFound|http:BadRequest|error {

        string|error org = getOrg(headers);
        if org is error {
            return org;
        }

        var bodyParts = check request.getBodyParts();
        Thumbnail thumbnail;
        if bodyParts.length() == 0 {
            thumbnail = {fileName: "", content: ""};
        } else {
            Thumbnail|error? handleContentResult = handleContent(bodyParts[0]);
            if handleContentResult is error {
                return http:BAD_REQUEST;
            }
            thumbnail = <Thumbnail>handleContentResult;
        }

        string|()|error thumbnailByDoctorId = updateThumbnailByDoctorId(org, doctorId, thumbnail);

        if thumbnailByDoctorId is error {
            return thumbnailByDoctorId;
        } else if thumbnailByDoctorId is () {
            return http:NOT_FOUND;
        }

        return http:OK;
    }

    # Get the thumbnail image of a doctor
    # + doctorId - ID of the doctor
    # + return - Return the thumbnail image or not found
    resource function get doctors/[string doctorId]/thumbnail(http:Headers headers) returns http:Response|http:NotFound|error {

        string|error org = getOrg(headers);
        if org is error {
            return org;
        }

        Thumbnail|()|string|error thumbnail = getThumbnailByDoctorId(org, doctorId);
        http:Response response = new;

        if thumbnail is () {
            return http:NOT_FOUND;
        } else if thumbnail is error {
            return thumbnail;
        } else if thumbnail is string {
            return response;
        } else {

            string fileName = thumbnail.fileName;
            byte[] encodedContent = thumbnail.content.toBytes();
            byte[] base64Decoded = <byte[]>(check mime:base64Decode(encodedContent));

            response.setHeader("Content-Type", "application/octet-stream");
            response.setHeader("Content-Disposition", "attachment; filename=" + fileName);
            response.setBinaryPayload(base64Decoded);
        }

        return response;
    }

    # Get doctor's details
    # + return - Doctor details or not found 
    resource function get me(http:Headers headers) returns Doctor|http:NotFound|error? {

        [string, string]|error orgInfo = getOrgWithEmail(headers);
        if orgInfo is error {
            return orgInfo;
        }

        string org = orgInfo[0];
        string email = orgInfo[1];

        Doctor|()|error result = getDoctorByEmailAndOrg(org, email);
        if result is () {
            return http:NOT_FOUND;
        }
        return result;
    }

    # Get all bookings
    # + return - List of bookings or error
    resource function get bookings(http:Headers headers) returns Booking[]|error? {

        string|error org = getOrg(headers);
        if org is error {
            return org;
        }

        return getBookings(org);
    }

    # Create a new booking
    # + newBooking - basic booking details
    # + return - created booking record or error
    resource function post bookings(http:Headers headers, @http:Payload BookingItem newBooking) returns Booking|http:Created|http:BadRequest|error? {

        [string, string]|error orgInfo = getOrgWithEmail(headers);
        if orgInfo is error {
            return orgInfo;
        }

        string org = orgInfo[0];
        string email = orgInfo[1];

        Doctor|()|error doctor = getDoctorById(newBooking.doctorId);

        if doctor is Doctor {

            Booking|error booking = addBooking(newBooking, org, email);
            if booking is error {
                return booking;
            }

            error? sendEmailResult = sendEmail(booking, doctor);
            if sendEmailResult is error {
                log:printError("Error while sending email for the booking: ", sendEmailResult);
            }

            return booking;
        } else if doctor is () {
            log:printInfo("Doctor not found. [Booking Pet ID]:" + newBooking.petId + ", [Booking Doctor ID]:" + newBooking.doctorId);
            return http:BAD_REQUEST;
        } else {
            return doctor;
        }

    }

    # Get a booking by ID
    # + bookingId - ID of the booking
    # + return - Booking details or not found 
    resource function get bookings/[string bookingId](http:Headers headers) returns Booking|http:NotFound|error? {

        string|error org = getOrg(headers);
        if org is error {
            return org;
        }

        Booking|()|error result = getBookingByIdAndOrg(org, bookingId);
        if result is () {
            return http:NOT_FOUND;
        }
        return result;
    }

    # Update a booking
    # + bookingId - ID of the booking
    # + updatedBookingItem - updated booking details
    # + return - Booking details or not found 
    resource function put bookings/[string bookingId](http:Headers headers, @http:Payload BookingItem updatedBookingItem) returns Booking|http:NotFound|error? {

        string|error org = getOrg(headers);
        if org is error {
            return org;
        }

        Booking|()|error result = updateBookingById(org, bookingId, updatedBookingItem);
        if result is () {
            return http:NOT_FOUND;
        }
        return result;
    }

    # Delete a booking
    # + bookingId - ID of the booking
    # + return - Ok response or error
    resource function delete bookings/[string bookingId](http:Headers headers) returns http:NoContent|http:NotFound|error? {

        string|error org = getOrg(headers);
        if org is error {
            return org;
        }

        string|()|error result = deleteBookingById(org, bookingId);
        if result is () {
            return http:NOT_FOUND;
        } else if result is error {
            return result;
        }
        return http:NO_CONTENT;
    }

}

function getOrg(http:Headers headers) returns string|error {

    var jwtHeader = headers.getHeader("x-jwt-assertion");
    if jwtHeader is http:HeaderNotFoundError {
        return jwtHeader;
    }

    [jwt:Header, jwt:Payload] [_, payload] = check jwt:decode(jwtHeader);
    return getOrgFromPayload(payload);
}

function getOwner(http:Headers headers) returns [string, string]|error {

    var jwtHeader = headers.getHeader("x-jwt-assertion");
    if jwtHeader is http:HeaderNotFoundError {
        return jwtHeader;
    }

    [jwt:Header, jwt:Payload] [_, payload] = check jwt:decode(jwtHeader);
    return getOwnerFromPayload(payload);
}

function getOrgWithEmail(http:Headers headers) returns [string, string]|error {

    var jwtHeader = headers.getHeader("x-jwt-assertion");
    if jwtHeader is http:HeaderNotFoundError {
        return jwtHeader;
    }

    [jwt:Header, jwt:Payload] [_, payload] = check jwt:decode(jwtHeader);

    string org = getOrgFromPayload(payload);
    string emailAddress = payload["email"].toString();

    return [org, emailAddress];
}

function getOwnerFromPayload(jwt:Payload payload) returns [string, string] {

    string? subClaim = payload.sub;
    if subClaim is () {
        subClaim = "Test_Key_User";
    }

    string? user_org = payload["user_organization"].toString();

    if user_org is "" {
        user_org = "Test_Key_Org";
    }

    return [<string>subClaim, <string>user_org];
}

function getOrgFromPayload(jwt:Payload payload) returns string {

    string? user_org = payload["user_organization"].toString();

    if user_org is "" {
        user_org = "Test_Key_Org";
    }

    return <string>user_org;
}

function handleContent(mime:Entity bodyPart) returns Thumbnail|error? {

    var mediaType = mime:getMediaType(bodyPart.getContentType());
    mime:ContentDisposition contentDisposition = bodyPart.getContentDisposition();
    string fileName = contentDisposition.fileName;

    if mediaType is mime:MediaType {

        string baseType = mediaType.getBaseType();
        if mime:IMAGE_JPEG == baseType || mime:IMAGE_GIF == baseType || mime:IMAGE_PNG == baseType {

            byte[] bytes = check bodyPart.getByteArray();
            byte[] base64Encoded = <byte[]>(check mime:base64Encode(bytes));
            string base64EncodedString = check string:fromBytes(base64Encoded);

            Thumbnail thumbnail = {
                fileName: fileName,
                content: base64EncodedString
            };

            return thumbnail;
        }
    }

    return error("Unsupported media type found");
}
