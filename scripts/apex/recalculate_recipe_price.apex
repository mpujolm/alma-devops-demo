List<Recipe_Line_Item__c> items = [SELECT Id FROM Recipe_Line_Item__c];
update items;
System.debug('Updated ' + items.size() + ' Recipe_Line_Item__c records to trigger Update_Price_Recipe_Stored flow.');
