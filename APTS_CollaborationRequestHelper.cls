/*************************************************************
@Name: APTS_ProposalLineItemTriggerHelper
@Author: Mihir Shah (Apttus)
@CreateDate: 10 Nov, 2016 nnnnnnnnnn
@Description: Helper class to Perform operations on Colloboration Request Object.
@UsedBy: APTS_CollaborationRequestHandler
*************************************************************
@ModifiedBy: Mitul Parmar
@ModifiedDate: 20 Dec 2016
@ChangeDescription: Changed Factory currency from picklist to use CurrencyISOCode on Factory Object.
*************************************************************
@ModifiedBy: Santosh Kumar
@ModifiedDate: 3 Jan 2017
@ChangeDescription: Business Exchange Rates to be regenerated when ABB Source Location is changed.
*************************************************************
@ModifiedBy: Karsan Prajapati
@ModifiedDate: 5 Jan 2017
@ChangeDescription: Added a debug statement in 
() to debug an issue while child cart is being created.

@ModifiedBy: Santosh Kumar
@ModifiedDate: 22 Jan 2017
@ChangeDescription: Business Exchange Rates to be regenerated changed from batch to controller.

@ModifiedBy: Mihir shah
@ModifiedDate: 30-08-2017
@ChangeDescription: ABBPG-3982- Changed the class to withoutsharing

*************************************************************
@ModifiedBy: Mirali Khanderiya
@ModifiedDate: 28 Nov 2017
@ChangeDescription: Added associateQuoteWithQEH() method.
@hpalm : #13951
*************************************************************
@ModifiedBy: Mirali Khanderiya
@ModifiedDate: 04-Jan-2018
@ChangeDescription: createParentSubItems() method is added for HPALM #16506
***************************************************************/ 
public without sharing  class APTS_CollaborationRequestHelper {

    public static void defaultPLonCR( List<Apttus_Config2__CollaborationRequest__c> CRList,Map <Id, Apttus_Config2__CollaborationRequest__c> mapOldCollab) {
        System.debug('Inside DefaultPLonCR');
        
        Set<ID> PendingSouceLocationset = new Set<ID>();
        Map<ID, ID> PendingCRSourceMAP = new Map<ID, ID>();   
        Map<ID, ID> CRSourceMAP = new Map<ID, ID>();  
        Map<ID, String> ABBlocationToCurrencyMAP = new Map<ID,String>();     
        Set<String> CurrencySet = new Set<String>();            
        Map<ID, String> ABBlocationtoCollabMAP  = new Map<ID, String>();
        List<Apttus_Config2__LineItem__c> LIlist = new List<Apttus_Config2__LineItem__c>();
        for(Apttus_Config2__CollaborationRequest__c CR: [SELECT Id, Apttus_Config2__ChildConfigurationId__c, Apttus_Config2__PriceListId__c, (SELECT APTS_Transfer_Price_Currency__c, Apttus_Config2__PriceListId__c, APTS_ABB_Source_Location__c ,id FROM Apttus_Config2__LineItems__r LIMIT 1) FROM Apttus_Config2__CollaborationRequest__c WHERE id = :CRList]) {
           
            if(CR.Apttus_Config2__ChildConfigurationId__c == NULL){
                 LIlist  = CR.Apttus_Config2__LineItems__r;
            }
                if(!LIlist.isEmpty() && string.isnotblank(LIlist[0].APTS_ABB_Source_Location__c)) {                    
                    CRSourceMAP.put(CR.id, LIlist[0].APTS_ABB_Source_Location__c);
                    if(string.isnotblank(LIlist[0].APTS_Transfer_Price_Currency__c)) {

                        CurrencySet.add(LIlist[0].APTS_Transfer_Price_Currency__c); 
                        ABBlocationtoCollabMAP.put(CR.id , LIlist[0].APTS_ABB_Source_Location__c+LIlist[0].APTS_Transfer_Price_Currency__c );
                    } else {
                        //PendingSouceLocationset.add(LIlist[0].APTS_ABB_Source_Location__c);
                        PendingCRSourceMAP.put(CR.id, LIlist[0].APTS_ABB_Source_Location__c); 
                    }
                }
            
        }  

        System.debug('Inside PendingCRSourceMAP.values() :-----'+PendingCRSourceMAP.values());
         //changed from APTS_FCM_Factory_Currency__c to CurrencyIsoCode
        for(APTS_Factory__c oFactory : [SELECT Id, CurrencyIsoCode, APTS_ABB_Location__c FROM APTS_Factory__c WHERE APTS_ABB_Location__c = :PendingCRSourceMAP.values()]) {
            if(!ABBlocationToCurrencyMAP.containsKey(oFactory.APTS_ABB_Location__c)) {
                //changed from APTS_FCM_Factory_Currency__c to CurrencyIsoCode
                ABBlocationToCurrencyMAP.Put(oFactory.APTS_ABB_Location__c, oFactory.CurrencyIsoCode);
            }
        }

        for(ID CRID : PendingCRSourceMAP.keyset()) {
                ID ABBlocationid = PendingCRSourceMAP.get(CRID);
                CurrencySet.add(ABBlocationToCurrencyMAP.get(ABBlocationid)); 
                ABBlocationtoCollabMAP.put(CRID , ABBlocationid+ABBlocationToCurrencyMAP.get(ABBlocationid));  
        }

        System.debug('Inside PendingCRSourceMAP'+PendingCRSourceMAP);
        System.debug('Inside ABBlocationToCurrencyMAP'+ABBlocationToCurrencyMAP);
        System.debug('Inside CRSourceMAP'+CRSourceMAP);
        System.debug('Inside ABBlocationtoCollabMAP'+ABBlocationtoCollabMAP);
        System.debug('Inside CurrencySet'+CurrencySet);

        MAP<string,APTS_Location_PriceList_Mapping__c>  ALPMmap = new MAP<string,APTS_Location_PriceList_Mapping__c>();
        for(APTS_Location_PriceList_Mapping__c oPLMAP : [SELECT APTS_Price_List__c, APTS_Factory__r.APTS_ABB_Location__c, APTS_Price_List_currency__c FROM APTS_Location_PriceList_Mapping__c WHERE APTS_Factory__r.APTS_ABB_Location__c = :CRSourceMAP.values() AND APTS_Price_List_currency__c = :CurrencySet ]) {

            ALPMmap.put(oPLMAP.APTS_Factory__r.APTS_ABB_Location__c+oPLMAP.APTS_Price_List_currency__c , oPLMAP);
        }
        System.debug('ALPMmap :-----'+ALPMmap);
        for(Apttus_Config2__CollaborationRequest__c CR: CRList) {
            if(ABBlocationtoCollabMAP.containsKey(CR.Id)) {

                String skey = ABBlocationtoCollabMAP.get(CR.Id);
                System.debug('Inside skey'+skey);               
                if(ALPMmap.containsKey(skey)) {
                    CR.Apttus_Config2__PriceListId__c = ALPMmap.get(skey).APTS_Price_List__c; 
                    CR.APTS_ABB_Source_Location__c = CRSourceMAP.get(CR.Id);
                    System.debug('Inside CR.Apttus_Config2__PriceListId__c'+CR.Apttus_Config2__PriceListId__c); 
                }
            }
        }  
    }
    
    //Method Called on after Update when ABB Source Location is changed
    public static void PouplateBUExchangeRate(Map <Id, Apttus_Config2__CollaborationRequest__c> mapOldCollab,List <Apttus_Config2__CollaborationRequest__c> listNewCollab){
        Set<Id> setCRId = new Set<Id>();
        Set<Id> setConfigId = new Set<Id>();
        List<APTS_Business_unit_exchange_rate__c> listBU = new List<APTS_Business_unit_exchange_rate__c>();
        List<Apttus_Config2__ProductConfiguration__c> listProdconf = new List<Apttus_Config2__ProductConfiguration__c>();
        system.debug('PouplateBUExchangeRate :-------');
        try{
            for(Apttus_Config2__CollaborationRequest__c oCollabReq : listNewCollab){
                system.debug('Child Cart :--- '+oCollabReq.Apttus_Config2__ChildConfigurationId__c);
                system.debug('New Source Location :--- '+oCollabReq.APTS_ABB_Source_Location__c);
                system.debug('Old Source Location :--- '+mapOldCollab.get(oCollabReq.Id).APTS_ABB_Source_Location__c);
                if(string.isnotblank(oCollabReq.Apttus_Config2__ChildConfigurationId__c) && string.isnotblank(oCollabReq.APTS_ABB_Source_Location__c)
                    && ((mapOldCollab.get(oCollabReq.Id).Apttus_Config2__ChildConfigurationId__c != oCollabReq.Apttus_Config2__ChildConfigurationId__c) 
                             || (mapOldCollab.get(oCollabReq.Id).APTS_ABB_Source_Location__c != oCollabReq.APTS_ABB_Source_Location__c))) { 
                    setCRId.add(oCollabReq.Id);
                    system.debug('PouplateBUExchangeRate Update BU Exchange Rate Logic called :--- '+oCollabReq.Id);
                }
            }
            
            //Fetch Existing Business Unit Exchange Records having business Object as collaboration Request with particular collaboration Request
            if(setCRId!=null && !setCRId.isEmpty()){
                listBU = [select id,name,APTS_Product_Configuration__c from APTS_Business_unit_exchange_rate__c where
                          APTS_Product_Configuration__r.Apttus_Config2__CollaborationRequestId__c IN: setCRId and APTS_Product_Configuration__r.Apttus_Config2__BusinessObjectType__c =: APTS_Constants.BUSINESS_OBJECT_TYPE_CR];
                
                system.debug('listBU=='+listBU);
                if(listBU != null && !listBU.isEmpty()){
                    setConfigId.add(listBU[0].APTS_Product_Configuration__c);
                    delete listBU;
                }
                
                //If there are no Business Unit Exchange Records fetch ProductConfiguration using collaboration Request Id
                if(setConfigId.isEmpty()){
                    listProdconf = [select id from Apttus_Config2__ProductConfiguration__c where Apttus_Config2__CollaborationRequestId__c IN:setCRId and Apttus_Config2__BusinessObjectType__c =: APTS_Constants.BUSINESS_OBJECT_TYPE_CR];
                    system.debug('listProdconf ==' + listProdconf);
                    system.debug('setCRId ==' + setCRId);
                }
                    if(listProdconf!= null && !listProdconf.isEmpty()){
                        setConfigId.add(listProdconf[0].id);
                    }
                
                
                //Call the Batch to create Business Unit Exchange Records
                if(!setConfigId.isEmpty()){
                    /*APTS_BUExchangeRateBatch oBatch = new APTS_BUExchangeRateBatch(setConfigId);
                    Database.executeBatch(oBatch,1);*/
                    APTS_BUExchangeRate.generateBUExchangeRates(setConfigId);
                }
            }
            
        }catch(Exception e){
            system.debug('Catch Exception Msg ==' + e.getmessage());
            system.debug('Catch Exception StackTrace ==' + e.getStackTraceString());
            listNewCollab[0].addError(e.getmessage());
        }    
    }

    /**
    * @description : This method to link QEH records to Quotation when Collaboration is completed. This methos is called after updation of Collaboration request.
    * @author : Mirali Khanderiya
    * @CreateDate: 28/11/2017 
    * @hpalm : #13951
    */
    
    public static void associateQuoteWithQEH(Map <Id, Apttus_Config2__CollaborationRequest__c> mapOldCollab,List <Apttus_Config2__CollaborationRequest__c> listNewCollab){

        Set<Id> setConfigID = new Set<Id>();
        //Preparing set of child product configuration
        for(Apttus_Config2__CollaborationRequest__c oCollabReq : listNewCollab){
            if(!APTS_Constants.COLLAB_STATUS_ACCEPTED.equals(mapOldCollab.get(oCollabReq.Id).Apttus_Config2__Status__c) && APTS_Constants.COLLAB_STATUS_ACCEPTED.equals(oCollabReq.Apttus_Config2__Status__c) && String.isNotBlank(oCollabReq.Apttus_Config2__ChildConfigurationId__c)){
                setConfigID.add(oCollabReq.Apttus_Config2__ChildConfigurationId__c);
            }
        }

        if(!setConfigID.isEmpty()){
            //Fetch all the Quotation External Hyperlink records that are associated to child configuration's line items and not associated to any Quotation 
            List<APTS_Quotation_External_Hyperlink__c> listQEH = [SELECT id, APTS_Quotation__c, APTS_Line_Item__r.Apttus_Config2__ConfigurationId__c, APTS_Line_Item__r.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c FROM APTS_Quotation_External_Hyperlink__c where APTS_Line_Item__r.Apttus_Config2__ConfigurationId__c IN :setConfigID AND APTS_Quotation__c = NULL ];

            for(APTS_Quotation_External_Hyperlink__c oQEH : listQEH){
                oQEH.APTS_Quotation__c = oQEH.APTS_Line_Item__r.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c;
            }

            if(listQEH!=null && listQEH.size()>0){
                update listQEH;
            }
        }  
    }


    /**
    * @description : To Clone subitems from Child to Parent Line Item
    * @author : Mirali Khanderiya
    * @CreateDate: 04/01/2018
    * @hpalm : #16506
    */
    public static void createParentSubItems(Map <Id, Apttus_Config2__CollaborationRequest__c> mapOldCollab,List <Apttus_Config2__CollaborationRequest__c> listNewCollab){

        Set<Id> setCollabID = new Set<Id>();
        Set<Id> setParentConfigId = new Set<Id>();
        Set<Id> setChildConfigId = new Set<Id>();
        List<APTS_SubItem__c> lstSubItems;
        List<APTS_SubItem__c> lstParentSubItems;
        Map<ID,ID> mapChildParentLI = new Map<ID,ID>();
        //Preparing set of child product configuration
        for(Apttus_Config2__CollaborationRequest__c oCollabReq : listNewCollab){
            if(!APTS_Constants.COLLAB_STATUS_ACCEPTED.equals(mapOldCollab.get(oCollabReq.Id).Apttus_Config2__Status__c) && APTS_Constants.COLLAB_STATUS_ACCEPTED.equals(oCollabReq.Apttus_Config2__Status__c) ){
                setCollabID.add(oCollabReq.Id);
                setParentConfigId.add(oCollabReq.Apttus_Config2__ParentConfigurationId__c);
                setChildConfigId.add(oCollabReq.Apttus_Config2__ChildConfigurationId__c);
            }
        }

        //Fetch all lineitems from child and parent configuration for the collaboration request 
        List<Apttus_Config2__LineItem__c> listLineItems = [SELECT id, Apttus_Config2__LineNumber__c, Apttus_Config2__CollaborationParentLineNumber__c, Apttus_Config2__ConfigurationId__r.Apttus_Config2__CollaborationRequestId__c, Apttus_Config2__CollaborationRequestId__c FROM Apttus_Config2__LineItem__c WHERE (Apttus_Config2__CollaborationRequestId__c IN :setCollabID AND Apttus_Config2__ConfigurationId__c IN :setParentConfigId) OR Apttus_Config2__ConfigurationId__c IN :setChildConfigId];
        System.debug('[createParentSubItems] listLineItems :'+listLineItems);

        // Prepare map of child LineItem Id to Parent LineItem Id
        for(Apttus_Config2__LineItem__c oParentLI : listLineItems){
            for(Apttus_Config2__LineItem__c oChildLI : listLineItems){
                if(oParentLI.Apttus_Config2__CollaborationRequestId__c == oChildLI.Apttus_Config2__ConfigurationId__r.Apttus_Config2__CollaborationRequestId__c && oParentLI.Apttus_Config2__LineNumber__c == oChildLI.Apttus_Config2__CollaborationParentLineNumber__c){
                    mapChildParentLI.put(oChildLI.ID, oParentLI.ID);
                    break;
                }
            }
        }

        if(!mapChildParentLI.isEmpty()){
            lstSubItems = [select Id, APTS_Expected_Market_Price__c, APTS_Line_Item__c, APTS_Original_Sales_Price__c   , APTS_Quantity__c, APTS_Sales_Price__c, APTS_Standard_Discounts__c, APTS_Transfer_Price__c, APTS_Type__c from APTS_SubItem__c where APTS_Line_Item__c IN : mapChildParentLI.keyset()];
            lstParentSubItems = new List<APTS_SubItem__c>();

            for(APTS_SubItem__c oSubLI: lstSubItems){
                APTS_SubItem__c parentSubLI= new APTS_SubItem__c();
                parentSubLI.APTS_Expected_Market_Price__c=oSubLI.APTS_Expected_Market_Price__c;
                parentSubLI.APTS_Line_Item__c = mapChildParentLI.get(oSubLI.APTS_Line_Item__c);
                parentSubLI.APTS_Original_Sales_Price__c=oSubLI.APTS_Original_Sales_Price__c;
                parentSubLI.APTS_Quantity__c=oSubLI.APTS_Quantity__c;   
                parentSubLI.APTS_Sales_Price__c=oSubLI.APTS_Sales_Price__c;
                parentSubLI.APTS_Standard_Discounts__c=oSubLI.APTS_Standard_Discounts__c;
                parentSubLI.APTS_Transfer_Price__c=oSubLI.APTS_Transfer_Price__c;
                parentSubLI.APTS_Type__c=oSubLI.APTS_Type__c;
                lstParentSubItems.add(parentSubLI);
            }

            // All the existing SubItems from Parent Line Item are deleted
            delete [select Id from APTS_SubItem__c where APTS_Line_Item__c IN : mapChildParentLI.values()];

            // Insert SubItems to Parent LineItem
            if(!lstParentSubItems.isEmpty()){
                insert lstParentSubItems;
            }
            
        }
    }
    // US 1613 Order Quantity Editable for Standard Supply Modified By Kiran
    public static void updateCollabRequestType(List <Apttus_Config2__CollaborationRequest__c> listNewCollab, Map <Id, Apttus_Config2__CollaborationRequest__c> mapOldCollab){
                       for(Apttus_Config2__CollaborationRequest__c oCollabReq : listNewCollab){
                                 
                        if(APTS_Constants.COLLAB_STATUS_ACCEPTED.equals(mapOldCollab.get(oCollabReq.Id).Apttus_Config2__Status__c) && (APTS_Constants.COLLAB_STATUS_NEW.equals(oCollabReq.Apttus_Config2__Status__c) || APTS_Constants.COLLAB_STATUS_SUBMITTED.equals(oCollabReq.Apttus_Config2__Status__c))){
                           oCollabReq.Auto__c = false;
            }
        }
                               
     }// US 1613 ENDS
}