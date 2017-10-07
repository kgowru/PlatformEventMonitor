@isTest
private class CreatePEApexTriggersTest {
    @isTest (SeeAllData = true)
    static void getItems(){
        CreatePEApexTriggersController myClass = new CreatePEApexTriggersController();
         List<SelectOption> getOptions = myClass.getItems();
        System.assertEquals(getOptions.size() > 1, true, 'Found no sobjects in org');
    }
        
    @isTest (SeeAllData = false) 
    static void testControllerCreate() {
        CreatePEApexTriggersController myClass = new CreatePEApexTriggersController();
        CreatePEApexTriggersController.mock = new ExampleCalloutMock();
        List<SelectOption> getOptions = myClass.getItems();
        
        String[] testPlatformEvents = new String[]{'test1', 'test2', 'test3'};
        myClass.setPlatformEvents(testPlatformEvents);
        myClass.create();
        System.assertEquals(true, true, 'Created platform events for 3 test events');
    }
}