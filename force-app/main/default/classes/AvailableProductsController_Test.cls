/*
* @company name EI Technologies Lebanon
* @author Nour Absi
* @date 5-2-2021
* @description Test Class for AvailableProductsController
*/

@isTest
public class AvailableProductsController_Test {
    
    @TestSetup
    //Create all data
    public static void loadData()
    {           
        //Insert Account
        Account acc = new Account(Name='testAccount');
        insert acc; 
        
        //Create Product
        Product2 pro = new Product2(Name = 'iPhone X', Family = 'Mobile');
        Insert pro;
        
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        //Query for the Pricebook2 record, to check IsStandard field
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        System.assertEquals(true, standardPricebook.IsStandard);
        
        //Create the PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = pro.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        Insert pbe;
        
        //Query the PricebookEntry record
        pbe = [SELECT Id, Pricebook2.IsStandard FROM PricebookEntry];
        System.assertEquals(true, pbe.Pricebook2.IsStandard);
        
        //Insert Order
        Order order = new Order(Name='testOrder' , EffectiveDate = date.Today() , Status ='Draft' , Pricebook2Id = standardPricebook.Id , accountId = acc.id);
        insert order; 
    }
    
    @isTest
    public static void test_getProducts()
    {        
        Order ord = [SELECT Id FROM Order LIMIT 1];               
        Test.startTest();
        //get available products by putting the search key
        List<pricebookentry> priceBookEntries = AvailableProductsController.getProducts('ip' , 'Name', 'asc');
        //get available products by not putting the search key
        List<pricebookentry> priceBookEntries2 = AvailableProductsController.getProducts('' , 'Name', 'asc');
        Test.stopTest();      
        system.assertEquals('iPhone X', priceBookEntries[0].Name);
   

    }

    @isTest
    public static void test_insertUpdateOrderProducts()
    {        
        Order ord = [SELECT Id FROM Order LIMIT 1];               
        Test.startTest();
        List<pricebookentry> priceBookEntries = AvailableProductsController.getProducts('ip' , 'Name', 'asc');
        //Insert Order Item once
        AvailableProductsController.insertUpdateOrderProducts(JSON.serialize(priceBookEntries), ord.id);
        //Insert Order Item again
        AvailableProductsController.insertUpdateOrderProducts(JSON.serialize(priceBookEntries), ord.id);
        Test.stopTest();      
        List<OrderItem> orderItems = [Select id, product2.Name, orderId, quantity from OrderItem where orderId =: ord.id ];
        system.assertEquals('iPhone X' , orderItems[0].product2.Name);
        system.assertEquals(2 , orderItems[0].quantity);

    }


}