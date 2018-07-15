import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.*;

public class Main {

    private static final String output_file_name_oracle = "output/script_for_oracle.sql";
    private static final String output_file_name_mssql = "output/script_for_mssql.sql";

    public static void main(String[] args) throws IOException {
        String excelFilePath = "data/testexcel.xlsx";
        FileInputStream inputStream = new FileInputStream(new File(excelFilePath));

        Workbook workbook = new XSSFWorkbook(inputStream);


        OutputStreamWriter oracle_script_file = new OutputStreamWriter(new FileOutputStream(output_file_name_oracle), "UTF-8");
        OutputStreamWriter mssql_script_file = new OutputStreamWriter(new FileOutputStream(output_file_name_mssql), "UTF-8");

        for (int iindex = 0; iindex < workbook.getNumberOfSheets(); iindex++) {
            Sheet sheet = workbook.getSheetAt(iindex);
            for (int jindex = 1; jindex < sheet.getLastRowNum(); jindex++) {
                Row row = sheet.getRow(jindex);
                String script_key = row.getCell(0).toString();
                String script_value = row.getCell(1, Row.MissingCellPolicy.CREATE_NULL_AS_BLANK).toString();

                oracle_script_file.append("INSERT INTO SECLORECONFIG VALUES('" + script_key + "','" + script_value + "');\n");
                mssql_script_file.append("INSERT INTO SECLORECONFIG VALUES(N'" + script_key + "',N'" + script_value + "');\n");


            }
        }

        oracle_script_file.close();
        mssql_script_file.close();
    }
}
