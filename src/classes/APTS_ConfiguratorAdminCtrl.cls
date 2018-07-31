/*
* Temporary class for testing purpose for configurator admin functionality
*
* @author Chintan Mistry
* @created 2016-06-02 this is
*/
global class APTS_ConfiguratorAdminCtrl{
    public APTS_Configurator_Admin__c oConfigurator{get; set;}
    public static APTS_Configurator_Admin__c g_oConfigurator {get; set;}
    public String strExtConfiguratorConfigMode {get;set;}
    // Final URL with placeholders
    public String FinalURL_Placeholders{get; private set;}
    // Final URL with actual values
    public String FinalURL_Values{get; private set;}

    private static final String NL='\n';
    public static String strDbg {get;private set;}
    public static String strRetURL {get;set;}
    public static String strRetURLKey {get;set;}
    public ID idLineItem{get;set;}

    public static final String strEMPTY = '';
    public static final String PARAMS_SEPARATOR = '\n';
    public static final String KEY_VALUE_SEPARATOR = '=';
    public static final String OBJECT_FIELD_SEPARATOR = '.';
    public static final String OBJECT_FIELD_SEPARATOR_REGEX = '\\' + OBJECT_FIELD_SEPARATOR;
    public static final String QUERY_STRING_PARAMS_SEPARATOR = '&';
    public static final String QUERY_STRING_STARTCHAR = '?';
    // private static final String strEMPTY = '';
    public static final String strNULL = 'null';
    public static final String strSYS_DATA_SUFFIX = '##';

    // Metadata/System parameters
    // private Set<String> setSystemData = new Set<String>{'CURRENTUSER' + strSYS_DATA_SUFFIX,'MAILADDRESS' + strSYS_DATA_SUFFIX,'RETURNURI' + strSYS_DATA_SUFFIX,'RETURNURL' + strSYS_DATA_SUFFIX,'USER' + strSYS_DATA_SUFFIX,'USERLANG' + strSYS_DATA_SUFFIX,'USERLANGUAGE' + strSYS_DATA_SUFFIX,'USERNAME' + strSYS_DATA_SUFFIX,'USERTYPE' + strSYS_DATA_SUFFIX};

    private static final String strRETURNURL = 'RETURNURL';

    private static final String strCURRENTUSER = 'CURRENTUSER';
    private static final String strMAILADDRESS = 'MAILADDRESS';
    // private static final String strRETURNURI = 'RETURNURI';
    private static final String strUSER = 'USER';
    private static final String strUSERLANG = 'USERLANG';
    private static final String strUSERLANGUAGE = 'USERLANGUAGE';
    private static final String strUSERNAME = 'USERNAME';
    private static final String strUSERTYPE = 'USERTYPE';

    private static final String PREFIX_APEX = '/apex/';
    private static final String BASE_URL = Apttus__ComplySystemProperties__c.getAll().values()[0].Apttus__InstanceUrl__c;

    private Set<String> setSystemData = new Set<String>{strCURRENTUSER,strMAILADDRESS
        // ,strRETURNURI,strRETURNURL,
        ,strUSER,strUSERLANG,strUSERLANGUAGE,strUSERNAME,strUSERTYPE};
    private Set<String> setSystemDataPlaceHolders = new Set<String>();

    private static final Index indx = new Index();

    static{
        strDbg = NL;
    }

    public APTS_ConfiguratorAdminCtrl(ApexPages.StandardController stdController){
        // construct(stdController, strEMPTY);
        construct(stdController);
    }

    // public APTS_ConfiguratorAdminCtrl(ApexPages.StandardController stdController, final String strRetURL_l){
        // construct(stdController, strRetURL_l);
    // }

    // private void construct(ApexPages.StandardController stdController, final String strRetURL_l){
    private void construct(ApexPages.StandardController stdController){
        oConfigurator =  (APTS_Configurator_Admin__c)stdController.getRecord();
        // strDbg +=NL+'While constructing, oConfigurator: ' + oConfigurator
        // +NL+'param ID: ' + ApexPages.currentPage().getParameters().get('id')
        // ;

        // strRetURL = strRetURL_l;
        System.debug(strDbg);
    }

    public void getConfiguratorData(){
        try{
        g_oConfigurator = oConfigurator;
        System.debug('oConfigurator ===> '+oConfigurator);
        if(oConfigurator.id == null) return;

        oConfigurator = [
            select id,name,BAL_ID__c,Configurator_Description__c,Configurator_URL__c,
                    Factory_Location__c,Is_Disabled__c,Is_Disabled_Description__c,
                    URL_Parameters__c,URL_Parameters_fixed__c, Reconfig_Action_Parameter__c,
                    New_Action_Paramater__c, APTS_Copy_Action_Parameter__c
                from APTS_Configurator_Admin__c
                where id=:oConfigurator.Id
            ];

        strDbg +=
            +'\n oConfigurator.New_Action_Paramater__c: ' + oConfigurator.New_Action_Paramater__c
            +'\n oConfigurator.Reconfig_Action_Parameter__c: ' + oConfigurator.Reconfig_Action_Parameter__c
            +'\n strExtConfiguratorConfigMode: ' + strExtConfiguratorConfigMode
            + '\n APTS_Copy_Action_Parameter_c__c :'+ oConfigurator.APTS_Copy_Action_Parameter__c
            ;

        FinalURL_Placeholders = strEMPTY;//oConfigurator.Configurator_URL__c + QUERY_STRING_STARTCHAR;

        String[] astrKeyValuePair;
        String[] astrObjFieldPair;
        List<String> lstParams = oConfigurator.URL_Parameters__c.split(PARAMS_SEPARATOR);
        //Start: Jinal Bhatt
        if (!string.ISBlank(idLineItem)) {
            strDbg += '\n  : -------------->'+strExtConfiguratorConfigMode + ':' +oConfigurator.APTS_Copy_Action_Parameter__c;
            if (strExtConfiguratorConfigMode == APTS_CaptureInputForLSODataConstants.ReconfigConfiguratorMode && !String.IsBlank(oConfigurator.Reconfig_Action_Parameter__c)) {
                lstParams.addAll(oConfigurator.Reconfig_Action_Parameter__c.split(PARAMS_SEPARATOR));
            } else if (strExtConfiguratorConfigMode == APTS_CaptureInputForLSODataConstants.NewConfiguratorMode && !String.IsBlank(oConfigurator.New_Action_Paramater__c)) {
                lstParams.addAll(oConfigurator.New_Action_Paramater__c.split(PARAMS_SEPARATOR));
            } else if (strExtConfiguratorConfigMode == APTS_CaptureInputForLSODataConstants.CopyConfiguratorMode && !String.IsBlank(oConfigurator.APTS_Copy_Action_Parameter__c)) {
                lstParams.addAll(oConfigurator.APTS_Copy_Action_Parameter__c.split(PARAMS_SEPARATOR));
            }
        }
        //End
        String[] astr = lstParams;
        Integer sizeParams = astr.size();
        strDbg += '\n lstParams: ' + lstParams
            +'\n astr: ' + astr
            ;
        strDbg +=NL+'-----\nURL parameters - jinal' + sizeParams
        + NL+'setSystemData: ' + setSystemData;
        Map<String,String> mapValuesPlaceHolders = new Map<String,String>();
        Map<String,String> mapSysDataValuesPlaceHolders = new Map<String,String>();
        Boolean isSystemData = false;
        for(Integer i=1; i<=sizeParams; ++i){
            strDbg +=NL+'astr['+(i-1)+']: ' + astr[i-1];
            astrKeyValuePair = astr[i-1].split('=');
            strDbg +=NL+'astrKeyValuePair: ' + astrKeyValuePair;
            String strKey = astrKeyValuePair[0].trim();
            String strValue = astrKeyValuePair[1].trim().toUpperCase();

            //Tag the system data parameter with suffix
            isSystemData = setSystemData.contains(strValue);
            // if(setSystemData.contains(strValue)){
                // isSystemData = true;
                // strValue += strSYS_DATA_SUFFIX;
            // } else {
                // isSystemData = false;
            // }

            strDbg += NL + strKey + ' -- ' + strValue;
            // Process returnURL later -- append at the end after encoding
            if(strKey.equalsIgnoreCase(strRETURNURL)){
                strRetURLKey = strKey;
                strRetURL = strValue;
                strDbg += '\n RETURNURL: ' + strKey + ' -- ' + strValue;
            } else {
                FinalURL_Placeholders += strKey + KEY_VALUE_SEPARATOR + strValue + ((isSystemData)? strSYS_DATA_SUFFIX:strEMPTY) + ((i != sizeParams)? QUERY_STRING_PARAMS_SEPARATOR : strEMPTY);
            }

            // Initially, let the value part be null
            if(isSystemData){
                mapSysDataValuesPlaceHolders.put(strValue, null);
            } else {
                mapValuesPlaceHolders.put(strValue, null);
            }
        }

        // if(!String.isBlank(strRetURLKey)){ // ReturnURL present -- append it
            // FinalURL_Placeholders += QUERY_STRING_PARAMS_SEPARATOR + strRetURLKey + KEY_VALUE_SEPARATOR + strRetURL;
        // }

        // Fill in the map with actual values for the placeholders
        getActualValues(mapValuesPlaceHolders, mapSysDataValuesPlaceHolders, idLineItem);
        strDbg += NL + 'mapValuesPlaceHolders: jinal' + mapValuesPlaceHolders
            +NL+'mapSysDataValuesPlaceHolders:  jinal' + mapSysDataValuesPlaceHolders
        ;

        FinalURL_Values = FinalURL_Placeholders;
        strDbg += '\nFinalURL_Values (before replace): ' + FinalURL_Values;
        // Replace objects/fields with actual values in URL
        replaceURLValues(mapValuesPlaceHolders, false);
        // Replace system data with actual values in URL
        replaceURLValues(mapSysDataValuesPlaceHolders, true);
        strDbg += '\nFinalURL_Values (after replace): ' + FinalURL_Values;
        FinalURL_Placeholders = FinalURL_Values;
        strDbg += '\nFinal URL (placeholders):\n\t' + FinalURL_Placeholders;

        //BEG: Prepend the fixed URL parameters
        astr = oConfigurator.URL_Parameters_fixed__c.split(PARAMS_SEPARATOR);
        sizeParams = astr.size();
        // FinalURL_Values += QUERY_STRING_PARAMS_SEPARATOR;
        String strFixedURLParams = strEMPTY;
        for(Integer i=1; i<=sizeParams; ++i){
            // FinalURL_Values += astr[i-1].trim() + ((i != sizeParams)? QUERY_STRING_PARAMS_SEPARATOR : strEMPTY);
            strFixedURLParams += astr[i-1].trim() + QUERY_STRING_PARAMS_SEPARATOR;
        }
        FinalURL_Values = oConfigurator.Configurator_URL__c + QUERY_STRING_STARTCHAR + strFixedURLParams + FinalURL_Placeholders;
        //END: Prepend the fixed URL parameters

        // Append return URL, if available, at last
        if(!String.isBlank(strRetURL)){
            final String lastChar = FinalURL_Values.right(1);
            if(lastChar != QUERY_STRING_PARAMS_SEPARATOR && lastChar != QUERY_STRING_STARTCHAR){
                FinalURL_Values += QUERY_STRING_PARAMS_SEPARATOR;
            }
            FinalURL_Values += strRetURLKey + KEY_VALUE_SEPARATOR + APTS_ApttusIntegrationUtility.URLEncode(strRetURL);
        }
        strDbg += '\nFinal URL (values):\n\t' + FinalURL_Values;


        }catch(Exception e){
            strDbg += '\n\nERR: ' + e + '\nST: ' + e.getStackTraceString();
            System.debug(LoggingLevel.ERROR, strDbg);
        }


        System.debug(strDbg);
    }

    public void replaceURLValues(Map<String,String> mapActualValues, final Boolean isSuffixRequired){
        Set<String> setKeys = mapActualValues.keySet();
        String strValue;
        strDbg += NL + 'setKeys ' + setKeys + ' -- ' + isSuffixRequired;
        for(String strKey : setKeys){
            strValue = mapActualValues.get(strKey);
            if(strValue == null){
                strValue = strEMPTY; //strNULL;
            }
            strDbg += NL + '\tKey: ' + strKey
                +NL +'\tValue: ' + strValue
                ;

            // Process returnURL later -- append at the end after encoding
            if(strKey.equalsIgnoreCase(strRetURL)){
                strRetURL = BASE_URL + PREFIX_APEX + strValue.substringAfter(PREFIX_APEX);
                strDbg += '\n strRetURL: ' + strRetURL;
                continue;
            }

            FinalURL_Values = FinalURL_Values.replace(strKey + ((isSuffixRequired)? strSYS_DATA_SUFFIX : strEMPTY), strValue);
        }

    }

    public class Index{
        private final Integer BASE = 0;

        public final Integer PAV                    = BASE + 0;
        public final Integer LI                     = BASE + 1;
        public final Integer PC                     = BASE + 2;
        public final Integer PROPOSAL               = BASE + 3;
        public final Integer OPPORTUNITY            = BASE + 4;
        public final Integer ACCOUNT                = BASE + 5;
        public final Integer ABBLOCATION            = BASE + 6; //Jinal Bhatt
        public final Integer CONFACCMGT             = BASE + 7; // Configurator access mgt.

        public final Integer SIZE = BASE + 8;
    }

    public class SODetails{
        public DescribeSObjectResult descSOResult{get; private set;} // SO describe details
        public String strName{get; private set;} // SO name in uppercase
        public String strID{get;set;} // ID for this SO, if available
        public Set<String> setFields{get; private set;} // All fields in uppercase
        public List<String> lstRelatedFields{get;set;} // Fields to be included in SOQL - not provided by user/configuration,etc.
        public List<String> lstSoqlFields{get; set;} // Final fields to be included in SOQL
        public Map<String,String> mapSoqlFieldsValues{get; set;} // Final fields to be included in SOQL

        public SODetails(DescribeSObjectResult oDescSOResult){
            descSOResult = oDescSOResult;

            // Store the object name in uppercase
            strName = descSOResult.getName().toUpperCase();

            // Store the field name in uppercase
            setFields = new Set<String>();
            Set<String> setTempFields = oDescSOResult.fields.getMap().keySet();
            for(String strField : setTempFields){
                setFields.add(strField.toUpperCase());
            }
            setTempFields.clear(); // release
            lstRelatedFields = new List<String>();
            lstSoqlFields = new List<String>();
            mapSoqlFieldsValues = new Map<String,String>();
        }

        public SObject getQueryResults(){
            return this.getQueryResults('ID');
        }

        public SObject getQueryResults(final String strWhereField){
            if(lstSoqlFields.isEmpty() && lstRelatedFields.isEmpty())
                return null;

            lstSoqlFields.addAll(lstRelatedFields);
            strDbg += NL + '***\n' + strName + '\n\tAll Fields: ' + lstSoqlFields;

            // Remove duplicate fields
            Set<String> setAllFields = new Set<String>();
            setAllFields.addAll(lstSoqlFields);

            // Re-populate list with unique fields
            lstSoqlFields.clear();
            lstSoqlFields.addAll(setAllFields);
            strDbg += NL + '\tUnique Fields: ' + lstSoqlFields;

            SObject soObj = null;
            List<SObject> lstSO = getQueryResults(lstSoqlFields, strName, strID, strWhereField);
            strDbg += NL + 'lstSO: ' + lstSO;
            if(lstSO != null && !lstSO.isEmpty()){
                soObj = lstSO[0];
                strDbg += NL + '\tFinal field values:';
                for(String strFld : lstSoqlFields){
                    mapSoqlFieldsValues.put(strName + OBJECT_FIELD_SEPARATOR + strFld, (String)soObj.get(strFld));
                    //strDbg += NL + '\t\t' + strFld + ': ' + soObj.get(strFld);
                }
                strDbg += NL + '\t\t' + mapSoqlFieldsValues;
            }

            System.debug(strDbg);

            return soObj;
        }
    }

    public static void getActualValues(Map<String, String> mapObjFldPair, Map<String, String> mapSysDataPair, final ID idLI){
        Apttus_Proposal__Proposal__c oProposal= New Apttus_Proposal__Proposal__c();
        try{
        //BEG: Gather details for all relevant SObjects
        // Product attribute value
        SODetails sodPAV = new SODetails(Schema.Apttus_Config2__ProductAttributeValue__c.getSObjectType().getDescribe());

        // Configuration line item
        SODetails sodLI = new SODetails(Schema.Apttus_Config2__LineItem__c.getSObjectType().getDescribe());
        sodLI.strID = idLI; // store the ID
        sodLI.lstRelatedFields.add(Schema.SObjectType.Apttus_Config2__LineItem__c.fields.Apttus_Config2__ConfigurationId__c.getName().toUpperCase());
        sodLI.lstRelatedFields.add(Schema.SObjectType.Apttus_Config2__LineItem__c.fields.APTS_ABB_Source_Location__c.getName().toUpperCase());
        sodLI.lstRelatedFields.add(Schema.SObjectType.Apttus_Config2__LineItem__c.fields.APTS_Ext_Configurator_Config_Mode__c.getName().toUpperCase());

        // Product configuration
        SODetails sodPC = new SODetails(Schema.Apttus_Config2__ProductConfiguration__c.getSObjectType().getDescribe());
        sodPC.lstRelatedFields.add(Schema.SObjectType.Apttus_Config2__ProductConfiguration__c.fields.Apttus_QPConfig__Proposald__c.getName().toUpperCase());

        //Start: ABB Source Location - Jinal Bhatt
        SODetails sodABBLocation = new SODetails(Schema.ABB_Location__c.getSObjectType().getDescribe());
        sodABBLocation.lstRelatedFields.add(Schema.SObjectType.ABB_Location__c.fields.BALId__c.getName().toUpperCase());
        //End

        // Quote/Proposal
        SODetails sodProposal = new SODetails(Schema.Apttus_Proposal__Proposal__c.getSObjectType().getDescribe());
        sodProposal.lstRelatedFields.add(Schema.SObjectType.Apttus_Proposal__Proposal__c.fields.Apttus_Proposal__Opportunity__c.getName().toUpperCase());
        sodProposal.lstRelatedFields.add(Schema.SObjectType.Apttus_Proposal__Proposal__c.fields.APTS_LP_AccountCustomer__c.getName().toUpperCase());

        // Opportunity
        SODetails sodOpportunity = new SODetails(Schema.Opportunity.getSObjectType().getDescribe());

        // Account
        SODetails sodAccount = new SODetails(Schema.Account.getSObjectType().getDescribe());

        // Configurator Access Management
        SODetails sodConfiguratorAccessMgt = new SODetails(Schema.APTS_Configurator_Access_Management__c.getSObjectType().getDescribe());

        String[] arrSONames = new String[indx.SIZE];
        arrSONames[indx.PAV        ] = sodPAV.strName;
        arrSONames[indx.LI         ] = sodLI.strName;
        arrSONames[indx.PC         ] = sodPC.strName;
        arrSONames[indx.PROPOSAL   ] = sodProposal.strName;
        arrSONames[indx.OPPORTUNITY] = sodOpportunity.strName;
        arrSONames[indx.ACCOUNT    ] = sodAccount.strName;
        arrSONames[indx.ABBLOCATION] = sodABBLocation.strName; //Jinal Bhatt
        arrSONames[indx.CONFACCMGT ] = sodConfiguratorAccessMgt.strName;

        Map<String, SODetails> mapSODetails = new Map<String, SODetails>();
        mapSODetails.put(arrSONames[indx.PAV], sodPAV);
        mapSODetails.put(arrSONames[indx.LI], sodLI);
        mapSODetails.put(arrSONames[indx.PC], sodPC);
        mapSODetails.put(arrSONames[indx.PROPOSAL], sodProposal);
        mapSODetails.put(arrSONames[indx.OPPORTUNITY], sodOpportunity);
        mapSODetails.put(arrSONames[indx.ACCOUNT], sodAccount);
        mapSODetails.put(arrSONames[indx.ABBLOCATION], sodABBLocation); //Jinal Bhatt
        mapSODetails.put(arrSONames[indx.CONFACCMGT], sodConfiguratorAccessMgt);
        //END: Gather details for all relevant SObjects

        Set<String> setObjFldPair = mapObjFldPair.keySet();
        strDbg +=
        +NL+'setObjFldPair: ' + setObjFldPair
        +NL+'idLI: ' + idLI
        +'####### jinal '+sodLI.lstRelatedFields+'------>'+mapSODetails;

        String strObjFldPairUcase;
        String[] arrObjFldPair;
        //Create a reverse mapping from uppercase field names to actual supplied ones
        Map<String,String> mapReverMapUCaseToSupplied = new Map<String,String>();
        Boolean allSOFound = true;
        //BEG: Check whether object/field exist
        for(String strObjFldPair : setObjFldPair){
            strObjFldPairUcase = strObjFldPair.toUpperCase();
            mapReverMapUCaseToSupplied.put(strObjFldPairUcase, strObjFldPair);
            arrObjFldPair = strObjFldPairUcase.split(OBJECT_FIELD_SEPARATOR_REGEX);

            strDbg +=NL+'-----\n arrObjFldPair: ' + arrObjFldPair;
            final String strObj = arrObjFldPair[0];//.toUpperCase();
            //Map<String, Schema.SObjectType> mapGD = Schema.getGlobalDescribe();
            SODetails sod = mapSODetails.get(strObj);
            if(sod != null){
                strDbg += '\nObject found: ' + strObj;
            } else {
                //TODO ERR
                strDbg += '\nERR: Object NOT found: ' + strObj;
                allSOFound = false;
            }
            final String strFld = arrObjFldPair[1];//.toUpperCase();
            strDbg += 'jinal strFld----> : ' + strFld;
            if(sod.setFields.contains(strFld)){
                strDbg += '\nField found: ' + strFld;
            } else {
                //TODO ERR
                strDbg += '\nERR: Field NOT found: ' + strFld;
                allSOFound = false;
            }
            sod.lstSoqlFields.add(strFld);
            strDbg += NL+'lstSoqlFields ('+sod.strName+'): ' + sod.lstSoqlFields;
        }

        if(!allSOFound){
            //TODO ERR
            return;
        }
        //END: Check whether object/field exist

        strDbg +=
        +NL+'mapReverMapUCaseToSupplied: ' + mapReverMapUCaseToSupplied
        +NL+'sodPAV: ' + sodPAV.lstSoqlFields
        +NL+'sodLI: ' + sodLI.lstSoqlFields
        +NL+'sodPC: ' + sodPC.lstSoqlFields
        +NL+'sodProposal: ' + sodProposal.lstSoqlFields
        +NL+'sodOpportunity: ' + sodOpportunity.lstSoqlFields
        +NL+'sodAccount: ' + sodAccount.lstSoqlFields
        +NL+'sodABBLocation: ' + sodABBLocation.lstSoqlFields
        +NL+'sodConfiguratorAccessMgt: ' + sodConfiguratorAccessMgt.lstSoqlFields
        ;

        // Check for Line items
        Apttus_Config2__LineItem__c oLI = (Apttus_Config2__LineItem__c)sodLI.getQueryResults();
        if(oLI != null){
            sodPC.strID = oLI.Apttus_Config2__ConfigurationId__c;
            Apttus_Config2__ProductConfiguration__c oPC = (Apttus_Config2__ProductConfiguration__c)sodPC.getQueryResults();

            sodPAV.strID = oLI.ID;
            Apttus_Config2__ProductAttributeValue__c oPAV = (Apttus_Config2__ProductAttributeValue__c)sodPAV.getQueryResults('Apttus_Config2__LineItemId__c');

            // Start: Jinal Bhatt - ABB Location
            if(!String.isBlank(oLI.APTS_ABB_Source_Location__c)) {
                sodABBLocation.strID = oLI.APTS_ABB_Source_Location__c;
                ABB_Location__c oABBLocation = (ABB_Location__c)sodABBLocation.getQueryResults();
            }
            //End

            if(oPC != null){
                sodProposal.strID = oPC.Apttus_QPConfig__Proposald__c;
                oProposal = (Apttus_Proposal__Proposal__c)sodProposal.getQueryResults();
            }

                if(oProposal != null){
                    sodOpportunity.strID = oProposal.Apttus_Proposal__Opportunity__c;
                    Opportunity oOpp = (Opportunity)sodOpportunity.getQueryResults();

                    sodAccount.strID = oProposal.APTS_LP_AccountCustomer__c;
                    Account oAcc = (Account)sodAccount.getQueryResults();
                }
            

            strDbg += '\n g_oConfigurator: ' + g_oConfigurator;
            List<APTS_Configurator_Access_Management__c> lstConfigAccMgt =
                [select Id, Name, APTS_Access_Level__c, APTS_Configurator_Access__r.name, APTS_Configurator_Assignee__r.name
                    from APTS_Configurator_Access_Management__c
                    where APTS_Configurator_Access__c = :g_oConfigurator.Id
                      and APTS_Configurator_Assignee__c = :UserInfo.getUserId()
                ];
            if(lstConfigAccMgt != null && !lstConfigAccMgt.isEmpty()){
                sodConfiguratorAccessMgt.strID = lstConfigAccMgt[0].Id;
                sodConfiguratorAccessMgt.getQueryResults();
            }
        } else {
            strDbg += '\nERR: No Line Item with ID: ' + idLI;
        }

        mapTheActualValues(sodPAV, mapReverMapUCaseToSupplied, mapObjFldPair);
        mapTheActualValues(sodLI, mapReverMapUCaseToSupplied, mapObjFldPair);
        mapTheActualValues(sodPC, mapReverMapUCaseToSupplied, mapObjFldPair);
        mapTheActualValues(sodProposal, mapReverMapUCaseToSupplied, mapObjFldPair);
        mapTheActualValues(sodOpportunity, mapReverMapUCaseToSupplied, mapObjFldPair);
        mapTheActualValues(sodAccount, mapReverMapUCaseToSupplied, mapObjFldPair);
        mapTheActualValues(sodABBLocation, mapReverMapUCaseToSupplied, mapObjFldPair); //Jinal Bhatt
        mapTheActualValues(sodConfiguratorAccessMgt, mapReverMapUCaseToSupplied, mapObjFldPair);

        //BEG: Populate the system data
        getSysData(mapSysDataPair);
        //END: Populate the system data

        strDbg += '\n\nFinal map: ' + mapObjFldPair
        +'\nSysData map: ' + mapSysDataPair
        ;

        }catch(Exception e){
            strDbg += '\n\nERR: ' + e + '\nST: ' + e.getStackTraceString();
            //TODO ERR
        }
        System.debug(strDbg);
    }

    public static void getSysData(Map<String,String> mapSysDataPair){
        final Set<String> setSysDataKeys = mapSysDataPair.keySet();
        String strValue = null;
        for(String strKey : setSysDataKeys){
            if(strCURRENTUSER == strKey || strUSERNAME == strKey){
                strValue = UserInfo.getUserName();
            }
            else if(strMAILADDRESS == strKey || strUSER == strKey){
                strValue = UserInfo.getUserEmail();
            }
            // else if(strRETURNURI == strKey){
                // strValue = strRetURL;
            // }
            else if(strUSERLANG == strKey || strUSERLANGUAGE == strKey){
                strValue = UserInfo.getLanguage();
            }
            else if(strUSERTYPE == strKey){
                strValue = UserInfo.getUserType();
            }
            mapSysDataPair.put(strKey, strValue);
        }
    }

    public static void mapTheActualValues(SODetails sod, Map<String,String> mapReverMapUCaseToSupplied, Map<String, String> mapObjFldPair){
        strDbg += NL + 'Finalizing for: '+ sod.strName
        +NL+ '\tmapReverMapUCaseToSupplied: ' + mapReverMapUCaseToSupplied
        +NL+ '\tmapObjFldPair: ' + mapObjFldPair
        ;
        String strReverseMappedField;
        String strKey;
        for(String strField : sod.lstSoqlFields){
            strKey = sod.strName + OBJECT_FIELD_SEPARATOR + strField;
            strReverseMappedField = mapReverMapUCaseToSupplied.get(strKey);
            strDbg += '\n\t' + strKey + ': ' + strReverseMappedField;
            if(strReverseMappedField == null){
                continue;
            }
            strDbg += '\n\t\tAssigning value: ' + sod.mapSoqlFieldsValues.get(strKey);
            mapObjFldPair.put(strReverseMappedField, sod.mapSoqlFieldsValues.get(strKey));
        }
    }

    public static List<SObject> getQueryResults(final List<String>lstFields, final String strSO, final String idSO, final String strWhereField){
        final String strQuery = 'select ' + String.join(lstFields,',') + ' from '+ strSO +' where '+strWhereField+'=\'' + idSO +'\'';
        strDbg += NL + 'Query for ' + strSO + ':\n\t' + strQuery;
        System.debug(strDbg);
        return Database.query(strQuery);
        // return null;
    }

    // Class holding information from APTS_Configurator_Admin__c
    public class ConfiguratorWrapper{
        public ID idRec {get;set;}
        public String strName {get;set;}
        public String strURL {get;set;} // Holds the final URL: APTS_Configurator_Admin__c.FinalURL_Values
    }

    public static List<ConfiguratorWrapper> getConfiguratorURLs(final Apttus_Config2__LineItem__c oLI, final APTS_Configurator_Admin__c oConfigAdmin){
        String strDbg_l;
        List<ConfiguratorWrapper> lstConfigWrapper = new List<ConfiguratorWrapper>();

        try{
        APTS_ConfiguratorAdminCtrl oConfigurator;
        ConfiguratorWrapper oConfigWrapper;
        // if(!lstConfiguratorAdmin.isEmpty()){
            // for(APTS_Configurator_Admin__c oConfigAdmin_l : lstConfiguratorAdmin){
        oConfigurator = new APTS_ConfiguratorAdminCtrl(new ApexPages.StandardController(oConfigAdmin));
        oConfigurator.idLineItem = oLI.Id;
        oConfigurator.strExtConfiguratorConfigMode = oLI.APTS_Ext_Configurator_Config_Mode__c;
        oConfigurator.getConfiguratorData();

        oConfigWrapper = new ConfiguratorWrapper();
        oConfigWrapper.idRec = oConfigAdmin.ID;
        oConfigWrapper.strName = oConfigAdmin.name;
        oConfigWrapper.strURL = oConfigurator.FinalURL_Values;
        lstConfigWrapper.add(oConfigWrapper);
            // }
        // }

        strDbg_l +=NL+'lstConfigWrapper: ' + lstConfigWrapper;
        System.debug(strDbg_l);
        }catch(Exception e){
            strDbg_l +=NL+'ERR: ' + e + '\nST:\n' + e.getStackTraceString();
            System.debug(LoggingLevel.ERROR, strDbg_l);
        }

        return lstConfigWrapper;
    }

    // public static List<ConfiguratorWrapper> getConfiguratorURLs(APTS_GenerateQuoteFromActiveDocsCtrl.DebugStringWrapper oDebug, final ID idLineItem, final APTS_Configurator_Admin__c oConfigAdmin){
        // List<ConfiguratorWrapper> oConfigWrapper = getConfiguratorURLs(idLineItem, oConfigAdmin);
        // oDebug.strDebug += '################--------->'+strDbg;
        // return oConfigWrapper;
    // }
}