/**
 * Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
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

import { AxiosResponse } from "axios";
import { getPetInstance } from "../CreatePet/instance";
import { Pet } from "../../types/pet";

function timeout(delay: number) {
  return new Promise( res => setTimeout(res, delay) );
}

export async function getPet(accessToken: string, petId: string) {
    const headers = {
      Authorization: `Bearer ${accessToken}`,
    };
    // await timeout(1000);
    const response = await getPetInstance().get("/pets/" + petId, {
      headers: headers,
    });
    return response as AxiosResponse<Pet>;
  }