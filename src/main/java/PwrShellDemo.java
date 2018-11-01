import org.apache.commons.exec.ExecuteWatchdog;

import java.io.BufferedReader;
import java.io.InputStreamReader;

public class PwrShellDemo {


    public static void main(String args[]) {

        try
        {
            String command = "powershell.exe \"scripts/getmailbox.ps1\"";
            ExecuteWatchdog watchdog = new ExecuteWatchdog(99999999999L);
            Process powerShellProcess = Runtime.getRuntime().exec(command);

            if (watchdog != null)
            {
                watchdog.start(powerShellProcess);
            }
            BufferedReader stdInput = new BufferedReader(new InputStreamReader(powerShellProcess.getErrorStream()));
            String line;
            System.out.println("Output :");
            while ((line = stdInput.readLine()) != null)
            {
                System.out.println(line);
            }

        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

}
