import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

public class ReadJsonFile {

    public static void main(String args[]) throws Exception {

        byte[] mapData = Files.readAllBytes(Paths.get("c:/users/sandesh/out.txt"));

        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.configure(DeserializationFeature.ACCEPT_SINGLE_VALUE_AS_ARRAY, true);
        List<FSShellMailbox> llistMailbox = objectMapper.readValue(mapData, new TypeReference<ArrayList<FSShellMailbox>>() {
        });

        llistMailbox.forEach(e -> {
            System.out.println(e);
        });
    }

    static class FSShellMailbox {
        private String uniqueId;
        private String displayName;
        private String primaryEmail;
        private List<String> aliases;
        private List<String> members;

        public String getUniqueId() {
            return uniqueId;
        }

        public void setUniqueId(String uniqueId) {
            this.uniqueId = uniqueId;
        }

        public String getDisplayName() {
            return displayName;
        }

        public void setDisplayName(String displayName) {
            this.displayName = displayName;
        }

        public String getPrimaryEmail() {
            return primaryEmail;
        }

        public void setPrimaryEmail(String primaryEmail) {
            this.primaryEmail = primaryEmail;
        }

        public List<String> getAliases() {
            return aliases;
        }

        public void setAliases(List<String> aliases) {
            this.aliases = aliases;
        }

        public List<String> getMembers() {
            return members;
        }

        public void setMembers(List<String> members) {
            this.members = members;
        }

        @Override
        public String toString() {
            return "FSShellMailbox{" +
                    "uniqueId='" + uniqueId + '\'' +
                    ", displayName='" + displayName + '\'' +
                    ", primaryEmail='" + primaryEmail + '\'' +
                    ", aliases=" + aliases +
                    ", members=" + members +
                    '}';
        }
    }

}
