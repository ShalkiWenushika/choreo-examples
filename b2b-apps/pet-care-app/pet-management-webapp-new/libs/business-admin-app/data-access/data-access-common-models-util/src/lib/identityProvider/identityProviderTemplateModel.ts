/**
 * Copyright (c) 2022, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

import { ControllerCallParam } from "@b2bsample/shared/data-access/data-access-common-models-util";

export interface IdentityProviderTemplateModelAuthenticatorProperty {
    key?: string,
    value?: string,
    displayName?: string,
    readOnly?: boolean,
    description?: string,
    [key: string]: unknown
}

interface IdentityProviderTemplateModelAuthenticator {
    authenticatorId: string,
    isEnabled: boolean,
    properties: IdentityProviderTemplateModelAuthenticatorProperty[],
    [key: string]: unknown
}

interface IdentityProviderTemplateModelFederatedAuthenticator {
    authenticators: IdentityProviderTemplateModelAuthenticator[],
    defaultAuthenticatorId: string,
    [key: string]: unknown
}

interface IdentityProviderTemplateModelCertificate {
    jwksUri?: string,
    certificates?: string[]
}

export interface IdentityProviderTemplateModel extends ControllerCallParam {
    name: string,
    image?: string,
    alias?: string,
    certificate?: IdentityProviderTemplateModelCertificate,
    federatedAuthenticators?: IdentityProviderTemplateModelFederatedAuthenticator,
    [key: string]: unknown

}

export default IdentityProviderTemplateModel;
