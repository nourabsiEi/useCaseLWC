@isTest
public without sharing class OrderProductsController_Test {
    
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
        
        List<Product2> products = [Select Id from product2];
        List<Order> Orders = [Select Id from Order];
        OrderItem orderItem = new OrderItem( quantity = 1 , product2Id =products[0].Id , orderId = Orders[0].Id ,pricebookEntryId = pbe.id , unitPrice = 1020);
        insert orderItem;
    }
    
    @isTest
    public static void test_getOrderProducts()
    {        
        Order ord = [SELECT Id FROM Order LIMIT 1];               
        Test.startTest();
        //Get Order Item 
        List<OrderItem> orderItems = OrderProductsController.getOrderProductsInit( ord.id);
        //Get Order Item on screen re-render
        List<OrderItem> orderItems2 = OrderProductsController.getOrderProductOnChange(ord.id);
        Test.stopTest();      
        
        system.assertEquals('iPhone X' , orderItems[0].product2.Name);
        system.assertEquals('iPhone X' , orderItems2[0].product2.Name);
        
    }
}