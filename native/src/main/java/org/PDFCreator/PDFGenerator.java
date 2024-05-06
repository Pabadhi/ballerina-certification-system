/**
 * Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
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

package org.PDFCreator;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.font.PDType0Font;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import java.io.File;
import java.io.IOException;

public class PDFGenerator {
    /**
     * This method is used to generate a PDF file with the given text.
     * 
     * @param inputFilePath  The path to the input PDF file.
     * @param replacement    The text to be written on the PDF.
     * @param font_type      The font type to be used.
     * @param fontSize       The font size to be used.
     * @param centerX        The X coordinate of the center of the text.
     * @param centerY        The Y coordinate of the center of the text.
     * @param fontFilePath   The path to the custom font file.
     * @param outputFileName The name of the output PDF file.
     */
    
    public static void pdf(String inputFilePath, String replacement, String font_type, int fontSize, int centerX,
            int centerY, String fontFilePath, String outputFileName) {
        String outputDirectory = "outputs/";
        File inputFile = new File(inputFilePath);
        File outputDir = new File(outputDirectory);
        float nameHeight = 0;
        float nameWidth = 0;
        if (!outputDir.exists()) {
            outputDir.mkdirs();
        }
        String outputFilePath = outputDirectory + outputFileName;
        try (PDDocument pdfDocument = PDDocument.load(inputFile)) {
            PDPage page = pdfDocument.getPage(0);
            float centerXF = centerX < 0 ? (float) (page.getMediaBox().getWidth() / 2.0) : centerX;
            PDPageContentStream contentStream = new PDPageContentStream(pdfDocument, page,
                    PDPageContentStream.AppendMode.APPEND, true, true);
                    
            if ("CUSTOM".equals(font_type)) {
                File fontFile = new File(fontFilePath);
                PDType0Font font = PDType0Font.load(pdfDocument, fontFile);
                contentStream.setFont(font, fontSize);
                nameWidth = font.getStringWidth(replacement) / 1000 * fontSize;
                nameHeight = (font.getFontDescriptor().getCapHeight()) / 1000 * fontSize;

            } else {
                PDType1Font font = getFontByName.getFontByName(font_type);
                contentStream.setFont(font, fontSize);
                nameWidth = font.getStringWidth(replacement) / 1000 * fontSize;
                nameHeight = (font.getFontDescriptor().getCapHeight()) / 1000 * fontSize;
            }
            float posY = centerY + nameHeight + 7.5f;
            float posX = centerXF - (nameWidth / 2.0f);
            contentStream.beginText();
            contentStream.newLineAtOffset(posX, posY);
            contentStream.showText(replacement);
            contentStream.endText();
            contentStream.close();
            pdfDocument.save(outputFilePath);
            System.out.println("Name written successfully. Modified PDF saved to: " + outputFilePath);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
