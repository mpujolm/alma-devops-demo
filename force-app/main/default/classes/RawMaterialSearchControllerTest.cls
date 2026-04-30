@IsTest
private class RawMaterialSearchControllerTest {

    @TestSetup
    static void setup() {
        insert new List<Raw_Material__c>{
            new Raw_Material__c(Name = 'Aceite esencial de lavanda'),
            new Raw_Material__c(Name = 'Aceite esencial de rosa'),
            new Raw_Material__c(Name = 'Agua destilada')
        };
    }

    @IsTest
    static void searchReturnsMatches() {
        Test.startTest();
        List<Raw_Material__c> results = RawMaterialSearchController.searchByName('Aceite esencial');
        Test.stopTest();
        Assert.areEqual(2, results.size(), 'Should find 2 records matching "Aceite esencial"');
    }

    @IsTest
    static void searchEmptyTermReturnsEmpty() {
        Test.startTest();
        List<Raw_Material__c> results = RawMaterialSearchController.searchByName('');
        Test.stopTest();
        Assert.areEqual(0, results.size(), 'Should return empty list for blank search term');
    }

    @IsTest
    static void searchNoMatchesReturnsEmpty() {
        Test.startTest();
        List<Raw_Material__c> results = RawMaterialSearchController.searchByName('Cera de abeja');
        Test.stopTest();
        Assert.areEqual(0, results.size(), 'Should return empty list when no matches found');
    }

    @IsTest
    static void searchSingleCharReturnsEmpty() {
        Test.startTest();
        List<Raw_Material__c> results = RawMaterialSearchController.searchByName('A');
        Test.stopTest();
        Assert.areEqual(0, results.size(), 'Should return empty list for single character search');
    }
}