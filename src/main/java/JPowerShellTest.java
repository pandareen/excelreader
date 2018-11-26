import com.profesorfalken.jpowershell.PowerShell;
import com.profesorfalken.jpowershell.PowerShellResponse;

import java.util.HashMap;
import java.util.Map;

public class JPowerShellTest {
    public static void main(String args[])
    {
        PowerShell powerShell = PowerShell.openSession();
        Map<String, String> myConfig = new HashMap<String, String>();
        myConfig.put("maxWait", "10000");
        powerShell.configuration(myConfig);
        PowerShellResponse response = powerShell.executeScript("scripts/test.ps1", "-blah 'asdasd'");
        System.out.println(response.isTimeout());
        powerShell.close();
    }
}
