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

interface ConfigObject {
    baseUrl: string;
    clientID: string;
    scope: string[];
    signInRedirectURL: string;
    signOutRedirectURL: string;
    resourceServerURL: string;
}

export function getConfig() {
    const configObj: ConfigObject = {
      baseUrl: import.meta.env.VITE_BASE_URL,
      clientID: import.meta.env.VITE_CLIENT_ID,
      scope: import.meta.env.VITE_SCOPE.split(" "),
      signInRedirectURL: import.meta.env.VITE_SIGN_IN_REDIRECT_URL,
      signOutRedirectURL: import.meta.env.VITE_SIGN_OUT_REDIRECT_URL,
      resourceServerURL: import.meta.env.VITE_RESOURCE_SERVER_URL,
    };
  
    return configObj;
  }
