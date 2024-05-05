// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
// This line specifies the copyright holder and their website.

// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// This block mentions the licensing terms under which the file is provided.

// You may obtain a copy of the License at
// This line provides the URL where you can find the full text of the Apache License, Version 2.0.

// http://www.apache.org/licenses/LICENSE-2.0
// This line gives the specific location where the License can be obtained.

// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.
// These lines describe the conditions under which the software is distributed and disclaim any warranties or conditions.

import ballerina/file;
import ballerina/http;
import ballerina/io;
import ballerina/jballerina.java;
import ballerina/regex;
import ballerinax/googleapis.sheets as gsheets;

configurable string pdfFilePath = ?;
configurable string fontFilePath = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string refreshUrl = ?;
configurable string spreadsheetId = ?;



gsheets:Client spreadsheetClient = check new ({
    auth: {
        clientId,
        clientSecret,
        refreshToken,
        refreshUrl
    }
});

type ID record {
    string id;
};

string file_path = "";

public function PDFGenerator(handle inputFilePath, handle replacement, handle font_type, int fontsize, int centerX, int centerY, handle fontFilePath, handle outputFileName) = @java:Method {
    'class: "org.PDFCreator.PDFGenerator",
    name: "pdf"
} external;

public function certicateGeneration(string inputFilePath, string fontFilePath, string checkID, string sheetName) returns error? {
    gsheets:Column col = check spreadsheetClient->getColumn(spreadsheetId, sheetName, "C");
    int i = 1;
    while i < col.values.length() {
        gsheets:Row row = check spreadsheetClient->getRow(spreadsheetId, sheetName, i);
        if row.values[3].toString() == checkID {
            string replacement = col.values[i].toString();
            string font_type = row.values[6].toString();
            io:println(font_type);
            string fontsizeStr = row.values[7].toString();
            string centerXstr = row.values[4].toString();
            string centerYstr = row.values[5].toString();
            int|error f = int:fromString(fontsizeStr);
            int|error x = int:fromString(centerXstr);
            int|error y = int:fromString(centerYstr);
            int fontsize = 16;
            int centerX = -1;
            int centerY = 250;
            if (f is int) {
                fontsize = f;
            }
            if (x is int) {
                centerX = x;
            }
            if (y is int) {
                centerY = y;
            }
            io:println(replacement);
            string file_name = replacement + ".pdf";
            file_path = "outputs/" + file_name;
            handle javastrName = java:fromString(replacement);
            handle javafont_type = java:fromString(font_type);
            handle javafontPath = java:fromString(fontFilePath);
            handle pdfpath = java:fromString(inputFilePath);
            handle javaOurputfileName = java:fromString(file_name);
            PDFGenerator(pdfpath, javastrName, javafont_type, fontsize, centerX, centerY, javafontPath, javaOurputfileName);
            break;
        }
        i += 1;

    }
}

service / on new http:Listener(9090) {
    resource function get certificates/[string value]() returns http:Response|error {
        string[] data = regex:split(value, "-");
        string ID = data[1];
        string sheetName = data[0];
        error? err = certicateGeneration(pdfFilePath, fontFilePath, ID, sheetName);
        byte[] bytes = check io:fileReadBytes(file_path);
        http:Response response = new;
        if err == null {
            response.setPayload(bytes);
            response.statusCode = 200;
            response.setHeader("Content-Type", "application/pdf");
            response.setHeader("Content-Disposition", "inline; filename='certificate.pdf'");
            check file:remove(file_path);
        } else {
            response.setJsonPayload("invalid");
            response.statusCode = 400;
        }

        return response;
    }
}


