import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { refreshApex } from '@salesforce/apex';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';

import getCustomSettings from '@salesforce/apex/HDT_LC_ServicePointCustomSettings.getCustomSettings';
import getServicePoint from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.getServicePoint';
import createServicePoint from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.createServicePoint';
import confirmServicePoint from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.confirmServicePoint';

import getInstanceWrapAddressObject from '@salesforce/apex/HDT_UTL_ServicePoint.getInstanceWrapAddressObject';
import callService from '@salesforce/apex/HDT_WS_ArrichmentDataEntityInvoker.callService';
import extractDataFromArriccDataServiceWithExistingSp from '@salesforce/apex/HDT_UTL_ServicePoint.extractDataFromArriccDataServiceWithExistingSp';



export default class HdtTargetObjectCreateForm extends LightningElement {
    @api herokuAddressResponse;
    @api spNew;
    @api recordtype;
    @api accountid;
    @api selectedservicepoint;
    @api wrapObjectInput= [];
    @api wrapAddressObject;
    @api sale;
    @api fieldsWrapObject=[];
    data;
    objectApiName = 'ServicePoint__c';
    fieldsData;
    @track fieldsDataObject = [];
    fieldsAddress;
    fieldsAddressReq;
    @api fieldsAddressObject = [];
    @track allFieldsObject = [];
    allFieldsData;
    allFieldsDataReq;
    fieldsWithError = [];
    @track allFieldsObject = [];
    fieldsReady = false;
    servicePointCode;
    servicePointId;
    fillFieldsDataDisabled = true;
    verifyFieldsAddressDisabled = true;
    fieldsDataReq;
    fieldsDataWithError = [];
    fieldsAddressWithError = [];
    @track submitedAddressFields;
    @track allSubmitedFields = {};
    hasDataBeenFilled = false;
    hasAddressBeenVerified = false;
    loading = false;
    recordTypeId;
    @api servicePointRetrievedData={};
    fieldsDataRaw = '';
    fieldsDataReqRaw = '';
    customSettings;
    @track newServicePoint;
    validForm = true;
    verifyAddressDisabledOnUpdate = true;
    @api theRecord= [];
    @api rowsplitele = [];
    @api rowsplitgas = [];
    @api responseArriccData;
    isSap= false;
    isValid = false;
    isValidFields = false;
    @api isricercainsap;


    
    
    /**
     * Handle save button availability
     */
    get saveBtnDisabled(){
        console.log('HdtTargetObjectCreateForm - get saveBtnDisabled' + JSON.stringify(this.verifyAddressDisabledOnUpdate));
        if((this.selectedservicepoint != undefined && this.verifyAddressDisabledOnUpdate)
            || this.selectedservicepoint != undefined && !this.verifyAddressDisabledOnUpdate && this.hasAddressBeenVerified){
                console.log('saveBtnDisabled false');
            return false;
        } else {
            console.log('saveBtnDisabled true');
            return false;
        }
    }

    /**
     * Verify address data
     */
    handleAddressVerification(event){
        this.hasAddressBeenVerified = event.detail;
    }
    @api
    saveWrapObject(wrapObjectInput){
        console.log('wrapObjectInput in entrata'+ JSON.stringify(wrapObjectInput));
        this.wrapObjectInput = wrapObjectInput;
        console.log('wrapObjectInput in USCITA'+ JSON.stringify(this.wrapObjectInput));

    }

    /**
     * Split string and create array of fields
     * @param {*} fieldsDataRaw 
     */
    toArray(fieldsDataRaw){
        let fieldsData = fieldsDataRaw.split(",");
        let fieldsDataFinal = [];

        for (var i = 0; i < fieldsData.length; i++) {
            if(fieldsData[i] != ''){
                fieldsDataFinal.push(fieldsData[i].trim());
            }
        }

        return fieldsDataFinal;
    }


    fieldRequiredMapping(){
        console.log('fieldRequiredMapping START + FIELDSDATAREQ ******'+ JSON.stringify(this.fieldsDataReq));

        let mapFieldReq = new Map() ;

            if((this.rowsplitele!=undefined ||this.rowsplitele !='')&& this.recordtype.label ==='Punto Elettrico'){
                this.rowsplitele.forEach(element=>{
           
                    mapFieldReq.set(element,true);
                });         
            }
            else if((this.rowsplitgas!=undefined ||this.rowsplitgas !='') && this.recordtype.label === 'Punto Gas'){

                this.rowsplitgas.forEach(element=>{
           
                    mapFieldReq.set(element,true);
                });         
            }
                
       
        console.log('fieldRequiredMapping END + MAPFIELDREQ*****'+ JSON.stringify(mapFieldReq));
        return mapFieldReq;
    }

    /**
     * Form array of field objects
     * @param {*} fieldsData 
     * @param {*} fieldsDataReq 
     */
    toObject(fieldsData, fieldsDataReq){
        console.log('fieldsReq************^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^' + this.fieldsDataReq);

 
        let fieldsDataObject = [];
        let mapFieldReq = new Map() ;
        mapFieldReq = this.fieldRequiredMapping();
        console.log('mappa campi required ' + JSON.stringify(mapFieldReq));
        var fieldReqParse = fieldsDataReq.toString();
        let fieldReq = fieldReqParse.split(",");
        
        fieldsDataReq.forEach(element=>{
            mapFieldReq.set(element,true);

        });									   

        fieldsData.forEach(element => {
            
           if(this.selectedservicepoint != undefined){
           
            if(element == 'CommoditySector__c')
            {
             console.log('entra in Punto Elettrico CommoditySector__c');
             fieldsDataObject.push(
                 {
                     fieldname: element,
                     required : mapFieldReq.get(element),
                     value: this.servicePointRetrievedData[element],
                     disabled: true
                 }
             ) 
            }
            else if(( element == 'DisconnectibilityType__c' && this.servicePointRetrievedData['Disconnectable__c']=='SI'))
            {

                fieldsDataObject.push(
                    {
                        fieldname: element,
                        required : mapFieldReq.get(element),
                        value: '',
                        disabled: true
                    }
                ) 
            }
            else if(element=='SAPImplantCode__c'||element=='IsRemoteManaged__c')
            {

                fieldsDataObject.push(
                    {
                        fieldname: element,
                        required : mapFieldReq.get(element),
                        value: this.servicePointRetrievedData[element],
                        disabled: true
                    }
                ) 
            }
                        else if(element=='SAPImplantCode__c')
            {

                fieldsDataObject.push(
                    {
                        fieldname: element,
                        required : mapFieldReq.get(element),
                        value: this.servicePointRetrievedData[element],
                        disabled: true
                    }
                ) 
            }
            else
            {
                console.log('entra in else ++++' + JSON.stringify(element));
                fieldsDataObject.push(
                    {
                        fieldname: element,
                        required : mapFieldReq.get(element),
                        value: this.servicePointRetrievedData[element],
                        disabled: element == ('ServicePointCode__c') ? true : false

                    }
                ) 
            }


            }
            else {
                console.log('recordType :' + JSON.stringify(this.recordtype.label));

                if((this.recordtype.label == 'Punto Elettrico'&& element == 'CommoditySector__c'))
                {
                 console.log('entra in Punto Elettrico CommoditySector__c');
                 this.allSubmitedFields.CommoditySector__c = 'Energia Elettrica';
                 fieldsDataObject.push(
                     {
                         fieldname: element,
                         required : mapFieldReq.get(element),
                         value: 'Energia Elettrica',
                         disabled: true
                     }
                 ) 
                }else if((this.recordtype.label === 'Punto Elettrico'||this.recordtype.label === 'Punto Gas') && element === 'SAPImplantCode__c'){
                    console.log('entra in SAPImplantCode__c')
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required : mapFieldReq.get(element),
                            value: this.servicePointRetrievedData[element],
                            disabled: true
                        }
                    ) 
                }
                else if(this.recordtype.label === 'Punto Gas' && element === 'CommoditySector__c'){
                    
                this.allSubmitedFields.CommoditySector__c = 'Gas';
                 fieldsDataObject.push(
                     {
                         fieldname: element,
                         required : mapFieldReq.get(element),
                         value: 'Gas',
                         disabled: true
                     }
                 ) 
                }
                else if(this.recordtype.label === 'Punto Gas' && element === 'Pressure__c'){
                    
                    
                     fieldsDataObject.push(
                         {
                             fieldname: element,
                             required : mapFieldReq.get(element),
                             value: this.servicePointRetrievedData[element],
                             disabled: true
                         }
                     ) 
                    }
                else if(this.recordtype.label === 'Punto Gas' && element === 'RemiCode__c'){
                    console.log('entra in RemiCode__c')
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required : mapFieldReq.get(element),
                            value:this.servicePointRetrievedData[element],
                            disabled: true
                        }
                    ) 
                }
                else
                {
                 fieldsDataObject.push(
                     {
                         fieldname: element,
                         required : mapFieldReq.get(element),
                         value: '',
                         disabled: false
                     }
                 ) 
                }
            }


        });

        return fieldsDataObject;
    }

    toObjectAddressInit(data){

        let fieldsDataObject = [];
        console.log('');
        Object.keys(data).forEach(keys=> {
        
           

                fieldsDataObject.push(
                    {
                        fieldname: keys,
                        required : false,
                        value: '',
                        disabled: false
                    }
                ) 

        });

        return fieldsDataObject;
    }


	   
						   
	   
				   
							  
		
														   
																							   
																 
																						  
																				   
																									 

		
							
																			   
																						  
		
								   
																		
																				 
																						
	 


    handleCallServiceSap(selectedservicepoint){
        console.log('event detail callservicesap *************' + JSON.stringify(selectedservicepoint));
        let servicePointCode;

        let spCode =JSON.stringify(this.selectedservicepoint).split(',');
       
        spCode.forEach(element => {
        console.log('selectedservicepoint handleCallServiceSap ' + element);
        if(element.split(':')[0].includes('Codice Punto')){
            servicePointCode = element.split(':')[1];
        }
        if(element.split(':')[0].includes('ServicePointCode__c')){
            servicePointCode = element.split(':')[1];
        }

        });

        //servicePointCode =JSON.stringify(this.selectedservicepoint).split(',')[1].split(':')[1];
        
        let lenght = servicePointCode.length;
        let input = '';
        if(selectedservicepoint['Codice Punto']==undefined){
            input=servicePointCode.substring(1,lenght-1);
        }else{
            input=selectedservicepoint['Codice Punto'];
        }
        console.log('input : ' + JSON.stringify(input));
        
        let sp =selectedservicepoint;
        console.log('sp *****************' + JSON.stringify(sp));
        callService({contratto:'',pod:input}).then(data =>{
            
            console.log('data*******************' + JSON.stringify(data));
            if(data.statusCode=='200'){
                
                this.responseArriccData = data;
                if(this.servicePointRetrievedData == undefined){
                    console.log('entra in if servRetrievedData undefiend **********************');

                    extractDataFromArriccDataServiceWithExistingSp({sp:sp,response:data}).then(datas =>{
                        console.log('datas*************************' +  JSON.stringify(datas));
                        this.isSap= true;
                            this.servicePointRetrievedData=datas[0];
                            console.log('servicePointRetriviedData Id: ******');
                            console.log('servicePointRetriviedData commodity: ******'+JSON.stringify(this.servicePointRetrievedData['CommoditySector__c']));
                            
                            switch(this.servicePointRetrievedData['CommoditySector__c']){
                                case 'Energia Elettrica':
                                    console.log('entra in energia elettrica');
                                    this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldEle__c  : (this.customSettings.FieldEle__c == null || this.customSettings.FieldEle__c == null ? this.customSettings.FieldGeneric__c  :  this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldEle__c ) );
        
                                    this.fieldsDataReqRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldRequiredEle__c  : (this.customSettings.FieldRequiredEle__c == null || this.customSettings.FieldRequiredEle__c == null ? this.customSettings.FieldGeneric__c  :  this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldRequiredEle__c ) );
                                    break;
                                case 'Gas':

                                    this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldGas__c  : (this.customSettings.FieldGas__c == null || this.customSettings.FieldGas__c == null ? this.customSettings.FieldGeneric__c  :  this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldGas__c ) );
        
                                    this.fieldsDataReqRaw =(this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldRequiredGas__c  : (this.customSettings.FieldRequiredGas__c == null || this.customSettings.FieldRequiredGas__c == null ? this.customSettings.FieldGeneric__c  :  this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldRequiredGas__c ) );
                                    break;
                                }
        
                            
                            this.fieldsData = this.toArray(this.fieldsDataRaw);
                            this.fieldsDataReq = this.toArray(this.fieldsDataReqRaw);
                            console.log('fieldsDataObject before handleCallServiceSap'+ JSON.stringify(this.fieldsDataObject));
                            this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);
                            console.log('fieldsDataObject after handleCallServiceSap'+ JSON.stringify(this.fieldsDataObject));

                            this.template.querySelector("c-hdt-target-object-address-fields").handleAddressValuesIfSap(this.servicePointRetrievedData);
                                                          
                            
                    });
                }else{
                    console.log('entra in else **********************');
                    extractDataFromArriccDataServiceWithExistingSp({sp:this.servicePointRetrievedData,response:data}).then(datas =>{
                        console.log('datas*************************' +  JSON.stringify(datas));
                            this.servicePointRetrievedData=datas[0];
                            console.log('servicePointRetriviedData commodity: ******'+JSON.stringify(this.servicePointRetrievedData['CommoditySector__c']));
                            switch(this.servicePointRetrievedData['CommoditySector__c']){
                                case 'Energia Elettrica':
                                    console.log('entra in energia elettrica');
                                    this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldEle__c  : (this.customSettings.FieldEle__c == null || this.customSettings.FieldEle__c == null ? this.customSettings.FieldGeneric__c  :  this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldEle__c ) );
                                    this.fieldsDataReqRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldRequiredEle__c  : (this.customSettings.FieldRequiredEle__c == null || this.customSettings.FieldRequiredEle__c == null ? this.customSettings.FieldGeneric__c  :  this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldRequiredEle__c ) );
                                    break;
                                case 'Gas':
                                    this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldGas__c  : (this.customSettings.FieldGas__c == null || this.customSettings.FieldGas__c == null ? this.customSettings.FieldGeneric__c  :  this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldGas__c ) );
                                    this.fieldsDataReqRaw =(this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldRequiredGas__c  : (this.customSettings.FieldRequiredGas__c == null || this.customSettings.FieldRequiredGas__c == null ? this.customSettings.FieldGeneric__c  :  this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldRequiredGas__c ) );
                                    break;
                                }
        
                            this.fieldsData = this.toArray(this.fieldsDataRaw);
                            this.fieldsDataReq = this.toArray(this.fieldsDataReqRaw);
                            console.log('fieldsDataObject before handleCallServiceSap'+ JSON.stringify(this.fieldsDataObject));
                            this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);
                            console.log('fieldsDataObject after handleCallServiceSap'+ JSON.stringify(this.fieldsDataObject));
                            this.template.querySelector("c-hdt-target-object-address-fields").handleAddressValuesIfSap(this.servicePointRetrievedData);
                        });
                }


            }else{
                this.isSap= false;
            }
                
        });
        
        
    }
	
	

    /**
     * Organize fields data
     */
    manageFields(){
        //get main data fields
        
        this.fieldsData = this.toArray(this.fieldsDataRaw);
        console.log('datareqRaw *********************'+ JSON.stringify(this.fieldsDataReqRaw));
        this.fieldsDataReq = this.toArray(this.fieldsDataReqRaw);
        console.log('datareq *********************'+ JSON.stringify(this.fieldsDataReq ));
        this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);
        console.log('fieldsDataObject *********************'+ JSON.stringify(this.fieldsDataObject));

        //get address fields
        this.fieldsAddress = this.toArray(this.customSettings.FieldAddress__c);
        this.fieldsAddressReq = this.toArray(this.customSettings.FieldRequiredAddress__c);
        
        //merge all fields together
        this.allFieldsData = this.fieldsData.concat(this.fieldsAddress);
        this.allFieldsDataReq = this.fieldsDataReq.concat(this.fieldsAddressReq);
        this.allFieldsObject = this.toObject(this.allFieldsData, this.allFieldsDataReq);
    }

    connectedCallback(){
        this.loading = true;

        console.log('hdtTargetObjectForm - connectedCallback - recordtype: ', JSON.stringify(this.recordtype));
        getCustomSettings().then(data => {
            //get data fields based on recordtype label
            if(this.recordtype.label != undefined){
            switch(this.recordtype.label){
                case 'Punto Elettrico':
                    this.fieldsDataRaw = (data.FieldGeneric__c == null || data.FieldGeneric__c == undefined ? data.FieldEle__c  : (data.FieldEle__c == null || data.FieldEle__c == null ? data.FieldGeneric__c  :  data.FieldGeneric__c + ',' + data.FieldEle__c ) );
                    //this.fieldsDataRaw +=','+ data.FieldEle__c;
                    this.fieldsDataReqRaw = (data.Field_Required_Generic__c == null || data.Field_Required_Generic__c == undefined ? data.FieldRequiredEle__c  : (data.FieldRequiredEle__c == null || data.FieldRequiredEle__c == null ? data.Field_Required_Generic__c  :  data.Field_Required_Generic__c + ',' + data.FieldRequiredEle__c ) );
                    break;
                case 'Punto Gas':
                    this.fieldsDataRaw = (data.FieldGeneric__c == null || data.FieldGeneric__c == undefined ? data.FieldGas__c  : (data.FieldGas__c == null || data.FieldGas__c == null ? data.FieldGeneric__c  :  data.FieldGeneric__c + ',' + data.FieldGas__c ) );
                    //this.fieldsDataRaw = undefined || null  ? this.fieldsDataRaw += data.FieldGas__c :  this.fieldsDataRaw +=','+ data.FieldGas__c;

                     //this.fieldsDataReqRaw += data.FieldGas__c;

                    this.fieldsDataReqRaw = (data.Field_Required_Generic__c == null || data.Field_Required_Generic__c == undefined ? data.FieldRequiredGas__c  : (data.FieldRequiredGas__c == null || data.FieldRequiredGas__c == null ? data.Field_Required_Generic__c  :  data.Field_Required_Generic__c + ',' + data.FieldRequiredGas__c ) );
				 
				
            }
        }
		

            this.customSettings = data;
            console.log(JSON.stringify(this.selectedservicepoint)+'********selectedServicePoint');
            if(this.selectedservicepoint != undefined){
                
                this.fieldsDataRaw = 'RecordTypeId, RecordType.DeveloperName, ' + data.FieldEle__c + ', ' + data.FieldGas__c+','+ data.FieldGeneric__c;
                this.fieldsDataReqRaw = data.FieldRequiredEle__c + ', ' + data.FieldRequiredGas__c+','+ data.Field_Required_Generic__c;
                //this.fieldsDataReqRaw = data.FieldRequiredEle__c + ', ' + data.FieldRequiredGas__c;


                let queryFields = [...new Set(this.toArray(this.fieldsDataRaw + ', ' + this.customSettings.FieldAddress__c))];
                console.log('queryFields*************'+JSON.stringify(queryFields) );
                getServicePoint({code:this.selectedservicepoint['Codice Punto'],fields: queryFields.join()}).then(data =>{

                    this.handleCallServiceSap(this.selectedservicepoint);
                    this.servicePointRetrievedData = data[0];
                    console.log('servicePointRetriviedData: ******'+JSON.stringify(this.servicePointRetrievedData.RecordType.DeveloperName));
                    if(this.servicePointRetrievedData.RecordType.DeveloperName!= undefined){
                    switch(this.servicePointRetrievedData.RecordType.DeveloperName){
                        case 'HDT_RT_Ele':
                            this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldEle__c  : (this.customSettings.FieldEle__c == null || this.customSettings.FieldEle__c == null ? this.customSettings.FieldGeneric__c  :  this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldEle__c ) );

                           // this.fieldsDataRaw = this.customSettings.FieldEle__c;
                            this.fieldsDataReqRaw = (this.customSettings.Field_Required_Generic__c == null || this.customSettings.Field_Required_Generic__c == undefined ? this.customSettings.FieldRequiredEle__c  : (this.customSettings.FieldRequiredEle__c == null || this.customSettings.FieldRequiredEle__c == null ? this.customSettings.Field_Required_Generic__c  :  this.customSettings.Field_Required_Generic__c + ',' + this.customSettings.FieldRequiredEle__c ) );
                            break;
                        case 'HDT_RT_Gas':
                            this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldGas__c  : (this.customSettings.FieldGas__c == null || this.customSettings.FieldGas__c == null ? this.customSettings.FieldGeneric__c  :  this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldGas__c ) );

                           // this.fieldsDataRaw = this.customSettings.FieldGas__c;
                            this.fieldsDataReqRaw =(this.customSettings.Field_Required_Generic__c == null || this.customSettings.Field_Required_Generic__c == undefined ? this.customSettings.FieldRequiredGas__c  : (this.customSettings.FieldRequiredGas__c == null || this.customSettings.FieldRequiredGas__c == null ? this.customSettings.Field_Required_Generic__c  :  this.customSettings.Field_Required_Generic__c + ',' + this.customSettings.FieldRequiredGas__c ) );
                    }
                    }


                    this.manageFields();

                    //this.template.querySelector("c-hdt-target-object-address-fields").getInstanceWrapObject(this.servicePointRetrievedData);
                    this.getInstanceWrapObject(this.servicePointRetrievedData);

                }).catch(error => {
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: error.message,
                        variant: 'error'
                    });
                    this.dispatchEvent(toastErrorMessage);
                    console.log('error****'+error.message);
                });

            } else {
                console.log(this.selectedservicepoint+'selectedServicePoint');
                this.manageFields();
                console.log('fieldsData'+ this.fieldsAddress);
            }
            console.log('fieldsData'+ this.fieldsAddress);
            //fields have been loaded
            this.fieldsReady = true;
            this.loading = false;
        }).catch(error => {
            this.loading = false;
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }



    @api
    getInstanceWrapObject(servicePointRetrievedData){
        console.log('getInstanceWrapObject - START');
        console.log('getInstanceWrapObject - servicePointRetrievedData' +JSON.stringify(servicePointRetrievedData));
        getInstanceWrapAddressObject({s:servicePointRetrievedData}).then(data => {
            this.template.querySelector("c-hdt-target-object-address-fields").handleAddressValues(data);
            console.log('getInstanceWrapObject - getInstanceWrapAddressObject Start '+ JSON.stringify(data));
            //this.wrapAddressObject = this.toObjectAddressInit(data);
            
            console.log('getInstanceWrapObject - wrapAddressObject' + JSON.stringify(this.wrapAddressObject));
            //this.toObjectAddress();
            
        });
        
        console.log('getInstanceWrapObject - END');
    }


    /**
     * Pre-fill Account__c field on render
     */
    renderedCallback(){
        if(this.fieldsReady){
            if(this.selectedservicepoint == undefined){
                let accountField = this.template.querySelector('[data-name="Account__c"]');
                if(accountField != null || accountField != undefined){
                    accountField.value = this.accountid;
                }
            }
        }
    }

    /**
     * Reset fields loading when closing modal
     */
    disconnectedCallback(){
        this.fieldsReady = false;
    }

    /**
     * Handle fill fields button availability
     * @param {*} fieldName
     * @param {*} fieldValue
     */
    handleFillFieldsButtonAvailability(fieldName, fieldValue){
        if(fieldName == 'ServicePointCode__c'){
            
            this.servicePointCode = fieldValue;
            if (this.servicePointCode.length > 13 && this.selectedservicepoint == undefined) {
                this.fillFieldsDataDisabled = false;
            } else {
                this.fillFieldsDataDisabled = true;
            }

        }
    }

    /**
     * Get fields value
     * @param {*} event 
     */
    handleFieldsDataChange(event){
        console.log('handleFieldsDataChange START');
        this.handleFillFieldsButtonAvailability(event.target.fieldName, event.target.value);
        console.log('handleFieldsDataChange fieldName : ******' + JSON.stringify(event.target.fieldName) );
        console.log('handleFieldsDataChange value : ******' + JSON.stringify(event.target.value) );
        this.allSubmitedFields[event.target.fieldName] = event.target.value;
        
        this.validForm = true;


        if(event.target.fieldName =='Disconnectable__c' && event.target.value == 'SI'){
            console.log(' if event target = disconnectable SI');

            console.log('Object refresh servicePointRetrievedData' + JSON.stringify(this.servicePointRetrievedData));
            console.log('Object refresh fieldsData' + JSON.stringify(this.fieldsData));
            console.log('Object refresh fieldsDataObject' + JSON.stringify(this.fieldsDataObject));
			
																	   
            
            this.servicePointRetrievedData.Disconnectable__c = 'SI';

            this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);


        }
        if(event.target.fieldName =='Disconnectable__c' && event.target.value == 'NO'){
            console.log(' if event target = disconnectable NO');
            console.log('Object refresh servicePointRetrievedData' + JSON.stringify(this.servicePointRetrievedData));
            console.log('Object refresh fieldsData' + JSON.stringify(this.fieldsData));
            console.log('Object refresh fieldsDataObject' + JSON.stringify(this.fieldsDataObject));

            this.servicePointRetrievedData.Disconnectable__c = 'NO';

            this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);

    
        }
        console.log('handleFieldsDataChange END');
       

    }

    /**
     * Handle main data fields filling request
     */
    handleDataFieldsFilling(){
        // let inp = this.template.querySelectorAll(".fieldsData");

        // if(this.servicePointRetrievedData != undefined){

        // inp.forEach(function(element){
            
        //     element.value = 'test';
        // });

        // }

        this.hasDataBeenFilled = true;
    }

    /**
     * Close create form
     */
    closeCreateTargetObjectModal(){
        this.dispatchEvent(new CustomEvent('closecreateform'));
    }

    /**
     * Get submited address fields values
     * @param {*} event 
     */
    getSubmitedAddressFields(event){
																												  
        this.submitedAddressFields = event.detail;
        this.validForm = true;
    }

    /**
     * Check validity before saving
     */
    validationChecks(){
											  
																					
        if(this.selectedservicepoint != undefined){
																												
            if(Object.keys(this.allSubmitedFields).length != 0){
                for (var key in this.allSubmitedFields) {
                    this.servicePointRetrievedData[key] = this.allSubmitedFields[key];
                }
            }
			
            this.allSubmitedFields = this.servicePointRetrievedData;
																	   
        } else {
            this.allSubmitedFields.RecordTypeId = this.recordtype.value;
            this.allSubmitedFields.Account__c = this.accountid;
            this.allSubmitedFields.Name = this.servicePointCode;
        }

        if(this.submitedAddressFields != undefined){
																		 
            for (let [key, value] of Object.entries(this.submitedAddressFields)) {
                this.allSubmitedFields[key] = value;
            }
																	   
        }

      /*  for(var i=0; i<this.fieldsDataReq.length; i++){
            
            let reqdata = this.allSubmitedFields[this.fieldsDataReq[i]];

             if( reqdata == undefined || reqdata == '' ){
                this.validForm = false;
                this.fieldsDataWithError.push(this.fieldsDataReq[i]);
            }
        }
		   

        for(var i=0; i<this.fieldsAddressReq.length; i++){
            
            let reqaddr = this.allSubmitedFields[this.fieldsAddressReq[i]];

             if( reqaddr == undefined || reqaddr == '' ){
                this.validForm = false;
                this.fieldsAddressWithError.push(this.fieldsAddressReq[i]);
            }
									  
        }*/
											
    }
    
        updateServicePoint(){
        console.log('update START');
        console.log('servicePointRetrievedData : ' + JSON.stringify(this.servicePointRetrievedData));
        console.log('theRecord : ' + JSON.stringify(this.theRecord));

        if(this.servicePointRetrievedData!= undefined){

            if(this.servicePointRetrievedData['SupplyStreet__c'] != this.theRecord['Via']){
                this.servicePointRetrievedData['SupplyStreet__c'] = this.theRecord['Via'];
            }
            if(this.servicePointRetrievedData['SupplyCity__c'] != this.theRecord['Comune']){
                this.servicePointRetrievedData['SupplyCity__c'] = this.theRecord['Comune'];
            }
            if(this.servicePointRetrievedData['SupplyPostalCode__c'] != this.theRecord['CAP']){
                this.servicePointRetrievedData['SupplyPostalCode__c'] = this.theRecord['CAP'];
            }
            if(this.servicePointRetrievedData['SupplyCountry__c'] != this.theRecord['Stato']){
                this.servicePointRetrievedData['SupplyCountry__c'] = this.theRecord['Stato'];
            }
            if(this.servicePointRetrievedData['SupplyProvince__c'] != this.theRecord['Provincia']){
                this.servicePointRetrievedData['SupplyProvince__c'] = this.theRecord['Provincia'];
            }
            if(this.servicePointRetrievedData['SupplySAPCityCode__c'] != this.theRecord['Codice Comune SAP']){
                this.servicePointRetrievedData['SupplySAPCityCode__c'] = this.theRecord['Codice Comune SAP'];
            }
            if(this.servicePointRetrievedData['SupplySAPStreetCode__c'] != this.theRecord['Codice Via Stradario SAP']){
                this.servicePointRetrievedData['SupplySAPStreetCode__c'] = this.theRecord['Codice Via Stradario SAP'];
            }
            if(this.servicePointRetrievedData['SupplyStreetNumberExtension__c'] != this.theRecord['Estens.Civico']){
                this.servicePointRetrievedData['SupplyStreetNumberExtension__c'] = this.theRecord['Estens.Civico'];
            }
            if(this.servicePointRetrievedData['SupplyStreetNumber__c'] != this.theRecord['Civico']){
                this.servicePointRetrievedData['SupplyStreetNumber__c'] = this.theRecord['Civico'];
            }
            if(this.servicePointRetrievedData['SupplyIsAddressVerified__c'] != this.theRecord['Flag Verificato']){
                this.servicePointRetrievedData['SupplyIsAddressVerified__c'] = this.theRecord['Flag Verificato'];
            }
            if(this.servicePointRetrievedData['SupplyPlaceCode__c'] != this.theRecord['Codice Localita']){
                this.servicePointRetrievedData['SupplyPlaceCode__c'] = this.theRecord['Codice Localita'];
            }
            if(this.servicePointRetrievedData['SupplyPlace__c'] != this.theRecord['Localita']){
                this.servicePointRetrievedData['SupplyPlace__c'] = this.theRecord['Localita'];
            }
            
        }

        console.log('update END');
    }

    updateSubmitedField(){
        console.log(' updateSubmitedField START');
        console.log(' updateSubmitedField allSubmitedFields' + JSON.stringify(this.allSubmitedFields));
        console.log(' updateSubmitedField theRecord' + JSON.stringify(this.theRecord));
        if(this.allSubmitedFields!= undefined){

            if(this.allSubmitedFields['SupplyStreet__c'] != this.theRecord['Via']){
                this.allSubmitedFields['SupplyStreet__c'] = this.theRecord['Via'];
            }
            if(this.allSubmitedFields['SupplyCity__c'] != this.theRecord['Comune']){
                this.allSubmitedFields['SupplyCity__c'] = this.theRecord['Comune'];
            }
            if(this.allSubmitedFields['SupplyPostalCode__c'] != this.theRecord['CAP']){
                this.allSubmitedFields['SupplyPostalCode__c'] = this.theRecord['CAP'];
            }
            if(this.allSubmitedFields['SupplyCountry__c'] != this.theRecord['Stato']){
                this.allSubmitedFields['SupplyCountry__c'] = this.theRecord['Stato'];
            }
            if(this.allSubmitedFields['SupplyProvince__c'] != this.theRecord['Provincia']){
                this.allSubmitedFields['SupplyProvince__c'] = this.theRecord['Provincia'];
            }
            if(this.allSubmitedFields['SupplySAPCityCode__c'] != this.theRecord['Codice Comune SAP']){
                this.allSubmitedFields['SupplySAPCityCode__c'] = this.theRecord['Codice Comune SAP'];
            }
            if(this.allSubmitedFields['SupplySAPStreetCode__c'] != this.theRecord['Codice Via Stradario SAP']){
                this.allSubmitedFields['SupplySAPStreetCode__c'] = this.theRecord['Codice Via Stradario SAP'];
            }
            if(this.allSubmitedFields['SupplyStreetNumberExtension__c'] != this.theRecord['Estens.Civico']){
                this.allSubmitedFields['SupplyStreetNumberExtension__c'] = this.theRecord['Estens.Civico'];
            }
            if(this.allSubmitedFields['SupplyStreetNumber__c'] != this.theRecord['Civico']){
                this.allSubmitedFields['SupplyStreetNumber__c'] = this.theRecord['Civico'];
            }
            if(this.allSubmitedFields['SupplyIsAddressVerified__c'] != this.theRecord['Flag Verificato']){
                this.allSubmitedFields['SupplyIsAddressVerified__c'] = this.theRecord['Flag Verificato'];
            }
            if(this.allSubmitedFields['SupplyPlaceCode__c'] != this.theRecord['Codice Localita']){
                this.allSubmitedFields['SupplyPlaceCode__c'] = this.theRecord['Codice Localita'];
            }
            if(this.allSubmitedFields['SupplyPlace__c'] != this.theRecord['Localita']){
                this.allSubmitedFields['SupplyPlace__c'] = this.theRecord['Localita'];
            }
        }

    }

    alert(title,msg,variant){
        const event = ShowToastEvent({
            title: title,
            message:  msg,
            variant: variant
        });
        dispatchEvent(event);
    }

    validFields() {
        console.log('validFields START');
        let isValid = true;
        this.isValidFields = true;
        let concatBillingErrorFields = '';
        let concatAddressErrorFields = '';
        //Validate address
        if(!this.theRecord['Indirizzo Estero']){
            console.log('entra in if ind estero');
            if (!this.theRecord['Flag Verificato']) {
                console.log('entra in flag verificato false ');
                isValid = false;
                this.isValidFields = false;
               // this.saveErrorMessage.push('E\' necessario verificare l\'indirizzo per poter procedere al salvataggio');
                this.alert('Dati tabella','E\' necessario verificare l\'indirizzo per poter procedere al salvataggio','error')

            }
        } else {
            console.log('entra in else ind estero ');

            let foreignAddressMsg = 'Per poter salvare popolare i seguenti campi di indirizzo: ';
            if (this.theRecord['Stato'] === undefined || this.theRecord['Stato'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Stato, ');
            }
            if (this.theRecord['Provincia'] === undefined || this.theRecord['Provincia'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Provincia, ');
            }
            if (this.theRecord['Comune'] === undefined || this.theRecord['Comune'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Comune, ');
            }
            if (this.theRecord['Via'] === undefined || this.theRecord['Via'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Via, ');
            }
            if (this.theRecord['Civico'] === undefined || this.theRecord['Civico'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Civico, ');
            }
            if (this.theRecord['CAP'] === undefined || this.theRecord['CAP'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('CAP, ');
            }
            if (concatAddressErrorFields !== '') {
                isValid = false;
                this.isValidFields = false;
                //this.saveErrorMessage.push('Per poter salvare popolare i seguenti campi di indirizzo: ' + concatAddressErrorFields.slice(0, -2));
                this.alert('Dati tabella','Per poter salvare popolare i seguenti campi di indirizzo: ' + concatAddressErrorFields.slice(0, -2),'error')
            }
        }
        console.log('validFields END');

        return isValid;
    }

    /**
     * Handle new record creation
     */
    save(){
        console.log('save');

        this.theRecord = this.template.querySelector('c-hdt-target-object-address-fields').handleAddressFields();
        console.log('this.theRecord'+JSON.stringify(this.theRecord));

        if(this.theRecord['Stato']=='Italy'||this.theRecord['Stato']=='Italia'){
            this.theRecord['Stato']=='ITALIA';
        }

        this.validFields();
        if(this.isValidFields == true){

        
        this.validationChecks();

        if (this.validForm) {

            this.loading = true;

            if(this.selectedservicepoint != undefined){
                console.log('entra in confirm');
                this.updateServicePoint();
                this.confirm();
				
            } else {
                console.log('entra in create');
                this.updateSubmitedField();
                this.create();
            }

        } else {

            this.template.querySelector('c-hdt-target-object-address-fields').checkInvalidFields(this.fieldsAddressWithError);
            
            for(var i=0; i<this.fieldsDataWithError.length; i++){
            
                let dataName = "[data-name='"+this.fieldsDataWithError[i]+"']";
                let dataField = this.template.querySelector(dataName);
                dataField.reportValidity();
            }
            
        }
    }
    }

    /**
     * Get form title
     */
    get formTitle(){
        console.log('formTitle START');        
        let title = 'Service Point: ';
        console.log('sp ******* formtitle' + JSON.stringify(this.selectedservicepoint));

        if(this.selectedservicepoint != undefined){
            console.log('entra in selectedServicePoint != undefined ');
            
            if(this.selectedservicepoint['Codice Punto'] != undefined){
                console.log('entra in selectedservicepoint codice punto');
                
                title += this.selectedservicepoint['Codice Punto'];
            }
            else if(this.selectedservicepoint['Codice Punto'] == undefined){


                let sp =JSON.stringify(this.selectedservicepoint).split(',');
                
                sp.forEach(element => {
                console.log('selectedservicepoint formtitle ' + element);
                if(element.split(':')[0].includes('ServicePointCode__c')){
                    title += element.split(':')[1];
                }
                if(element.split(':')[0].includes('Codice Punto')){
                    title += element.split(':')[1];
                }
        
                });
                this.isSap=true;

            }
        } 
        else 
        {
            title += this.recordtype.label;
        }
        console.log('formTitle END');
        return title ;
    }

    /**
     * Get save button name
     */
    /*get saveButtonName(){
        if(this.selectedservicepoint != undefined){
            return '';
        } else {
            return 'Salva';
        }
    }*/

    /**
     * Get verify address for update case
     * @param {*} event 
     */
    handleVerifyAddressOnUpdate(event){
        this.verifyAddressDisabledOnUpdate = event.detail;
    }

    /**
     * Create record
     */
    create(){
								  
																				  

        createServicePoint({servicePoint: this.allSubmitedFields}).then(data =>{
            this.loading = false;
            this.closeCreateTargetObjectModal();
            this.servicePointId = data.id;
            this.newServicePoint = data;

																															 

            this.dispatchEvent(new CustomEvent('newservicepoint', {detail: this.newServicePoint}));
            this.dispatchEvent(new CustomEvent('confirmservicepoint', {detail: this.newServicePoint}));

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Service Point creato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);
            
        }).catch(error => {
            this.loading = false;

            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    /**
     * Confirm record
     */
    confirm(){
        console.log('confirm START');

        let submittedFieldsValidate=[];
        console.log('confirm allSubmitedFields ' + JSON.stringify(this.allSubmitedFields));
        console.log('confirm Id ' + JSON.stringify(this.allSubmitedFields['Id']));
        console.log('confirm isRicercainsap ' + JSON.stringify(this.isricercainsap));

        if(this.allSubmitedFields['Id'] != undefined && this.isricercainsap==true){
            console.log('REMOVE START');

            delete this.allSubmitedFields['Id'];

            console.log('REMOVE END');

        }
        confirmServicePoint({servicePoint: this.allSubmitedFields, sap: this.isSap}).then(data =>{
																				
            this.loading = false;
            this.closeCreateTargetObjectModal();
            this.servicePointId = data.id;
            this.newServicePoint = data;
            console.log('new Sp Id : ' + JSON.stringify(this.newServicePointId));
            console.log('new Sp : ' + JSON.stringify(this.newServicePoint));
            this.isSap= false;
            this.dispatchEvent(new CustomEvent('newservicepoint', {detail: this.newServicePoint}));
            this.dispatchEvent(new CustomEvent('confirmservicepoint', {detail: this.newServicePoint}));
            
        }).catch(error => {
            this.loading = false;

            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
									 
    }


    handleResponseHeroku(event){
        console.log('handleResponseHeroku event detail : ' + JSON.stringify(event.detail));
        this.herokuAddressResponse=event.detail;
    }
}