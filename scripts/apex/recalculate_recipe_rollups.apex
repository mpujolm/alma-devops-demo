// Recalculates Roll-Up Summary fields on Recipe__c (Total_Cost__c, Total_Quantity_ml__c)
// and triggers the Update_Price_Recipe_Stored flow for all Recipe_Line_Item__c records.
// Run this after importing data or after creating the Roll-Up Summary fields for the first time.
update [SELECT Id FROM Recipe_Line_Item__c];
