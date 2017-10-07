public class CreatePEApexTriggersController {
    String[] platformEvents = new String[]{};

    public static HttpCalloutMock mock = null;
    
    public PageReference test() {
 	 	return null;
 	}
    
    public List<SelectOption> getItems(){
        List<Schema.SObjectType> sObjects = Schema.getGlobalDescribe().values();
        List<String> platformEvents = new List<String>();
        List<SelectOption> options = new List<SelectOption>();
        for(Integer peNum = 0; peNum < sObjects.size(); peNum++){
            Schema.SObjectType o = sObjects.get(peNum); 
            Schema.DescribeSObjectResult objResult = o.getDescribe();
            String peApiName = objResult.getName();
            String peStart = peApiName.substring(0, peApiName.length()-3);
            String peEnding = peApiName.substring(peApiName.length()-3, peApiName.length());
            String peLabel = objResult.getLabel();
            if(peEnding == '__e'){
                platformEvents.add(peLabel + ' [' + peApiName + ']');
                options.add(new SelectOption(peApiName, peApiName));
            }
        }
        return options;
    }
    
    public String[] getPlatformEvents() {
  	 	return platformEvents;
 	}

 	public void setPlatformEvents(String[] platformEvents) {
 	 	this.platformEvents = platformEvents;
 	}
    
    public void create(){
        if(platformEvents.size() != 0){
            String json = '['; Integer firstPe = 0;
            List<Schema.SObjectType> sObjects = Schema.getGlobalDescribe().values();
            Integer commaNum = 0;
            for(Integer peNum = 0; peNum < sObjects.size(); peNum++){
                Schema.SObjectType o = sObjects.get(peNum); 
                Schema.DescribeSObjectResult objResult = o.getDescribe();
                String peApiName = objResult.getName(); 
                String peStart = peApiName.substring(0, peApiName.length()-3);
                String peEnding = peApiName.substring(peApiName.length()-3, peApiName.length());
                String peLabel = objResult.getLabel();
                
                for(Integer i=0; i< platformEvents.size(); i++){
                    if(peApiName == platformEvents.get(i)){
                        if(commaNum != 0){
                        	json = json + ',';
                        }
                        String apexTriggerName = 'peTriggerFor' + peLabel;
                        json = json + '{"method": "POST", "url": "/services/data/v40.0/sobjects/ApexTrigger", "richInput" :{ "Name" : "' + apexTriggerName + '", "TableEnumOrId" : "' + peApiName + '", "Body" : "trigger ' + apexTriggerName + ' on ' + peApiName + '(after insert) { DescribeSObjectResult describe = ' + peApiName + '.sObjectType.getDescribe(); String label = describe.getLabel(); for (' + peApiName + ' event : Trigger.New) { DateTime peCreatedDateTime = event.CreatedDate; DateTime myDateTime = DateTime.newInstance(peCreatedDateTime.year(), peCreatedDateTime.month(), peCreatedDateTime.day(), peCreatedDateTime.hour(), peCreatedDateTime.minute(), 0); String stringMyDateTime = String.valueOf(myDateTime); List<pemonitor__CountPlatformEvent__c> countPEObjects = [SELECT Id, pemonitor__pecount__c, pemonitor__pename__c, pemonitor__pedatetime__c FROM pemonitor__CountPlatformEvent__c  WHERE pemonitor__pedatetime__c = :myDateTime AND pemonitor__pename__c = \'' + peApiName + '\' LIMIT 1]; if(!countPEObjects.isEmpty()){ pemonitor__CountPlatformEvent__c  countPEObject = countPEObjects[0]; try { Decimal countPe = countPEObject.pemonitor__pecount__c; countPe = countPe + 1; countPEObject.pemonitor__pecount__c = countPe; update countPEObject; } catch (Exception e) { System.debug(\'An unexpected error has occurred: \'+ e.getMessage()); } } else { pemonitor__CountPlatformEvent__c countPEObject = new pemonitor__CountPlatformEvent__c(pemonitor__pecount__c = 1, pemonitor__pedatetime__c = myDateTime, pemonitor__pename__c = \'' + peApiName + '\', pemonitor__pelabel__c = label) ; try{ insert countPEObject; } catch (DmlException e){ System.debug(\'An unexpected error has occurred: \'+ e.getMessage()); } } } }" }}'; 
                        commaNum = commaNum + 1;
                    }
                    
                }
            }
            json = json + ']';
            
            String myUrl = System.Url.getSalesforceBaseURL().toExternalForm().substringBefore('.visual').substringAfter('.');
            
            myUrl = 'https://' + myUrl + '.salesforce.com';
            HttpRequest req = new HttpRequest(); 
            req.setEndpoint(myUrl + '/services/data/v40.0/composite/batch'); 
            req.setMethod('POST'); 
            req.setHeader('Content-Type', 'application/json'); 
            req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId()); 
            String updatedJson = '{"batchRequests":' + json + '}'; 
            req.setBody(updatedJson); 
            if(Test.isRunningTest() && (mock!=null)){
                mock.respond(req);
            } else {
                Http httpReq = new Http(); 
                HttpResponse res = httpReq.send(req); 
                System.debug('HTTP RESPONSE' + res);
            }
        }
    }
    
}