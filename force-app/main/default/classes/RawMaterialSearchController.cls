public with sharing class RawMaterialSearchController {
    @AuraEnabled(cacheable=true)
    public static List<Raw_Material__c> searchByName(String searchTerm) {
        if (String.isBlank(searchTerm) || searchTerm.length() < 2) {
            return new List<Raw_Material__c>();
        }
        String likePattern = '%' + String.escapeSingleQuotes(searchTerm) + '%';
        return [
            SELECT Id, Name, Material_Category__c, Price__c, Quantity__c
            FROM Raw_Material__c
            WHERE Name LIKE :likePattern
            ORDER BY Name
            LIMIT 10
        ];
    }
}
