import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { refreshApex } from '@salesforce/apex';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';

import getCustomSettings from '@salesforce/apex/HDT_LC_ServicePointCustomSettings.getCustomSettings';
import getServicePoint from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.getServicePoint';
import createServicePoint from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.createServicePoint2';
import canHandleTari from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.canHandleTari';
import createServicePoinString from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.createServicePoinString';
import confirmServicePoint from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.confirmServicePoint2';
import getDistributorPointCode from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.getDistributorPointCode';
import getATO from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.getAto';
import checkFieldCoerenceSpGas from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.checkFieldCoerenceSpGas';
import checkCoerenceServicePoint from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.checkCoerenceServicePoint';
import getInstanceWrapAddressObject from '@salesforce/apex/HDT_UTL_ServicePoint.getInstanceWrapAddressObject';
import callService from '@salesforce/apex/HDT_WS_ArrichmentDataEntityInvoker.callService';
import extractDataFromArriccDataServiceWithExistingSp from '@salesforce/apex/HDT_UTL_ServicePoint.extractDataFromArriccDataServiceWithExistingSp';
import isInBlacklist from '@salesforce/apex/HDT_LC_AdvancedSearch.isInBlacklist';
import searchModificaContratti from '@salesforce/apex/HDT_LC_AdvancedSearch.searchModificaContratti';

import ACCOUNT_RECORDTYPE_FIELD from '@salesforce/schema/Account.RecordTypeId';
import Name from '@salesforce/schema/Account.Name';
import CategoriaCliente from '@salesforce/schema/Account.Category__c';
import rejectActivityDocument from '@salesforce/apex/HDT_UTL_ActivityCustom.rejectActivityDocument';


export default class HdtTargetObjectCreateForm extends LightningElement {
    @api herokuAddressResponse;
    @api spNew;
    @api recordtype;
    @api accountid;
    @api customercode;
    @api selectedservicepoint;
    @api wrapObjectInput = [];
    @api wrapAddressObject;
    @api sale;
    @api fieldsWrapObject = [];

    @track recordTypeAccount;
    @api accRecord;

    @wire(getRecord, { recordId: '$accountid', fields: [ACCOUNT_RECORDTYPE_FIELD, Name, CategoriaCliente] })
    wiredRecord({ error, data }) {
        if (data) {
            this.accRecord = data;
            let record = data;
            this.recordTypeAccount = record.recordTypeInfo.name;
        }
    }
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
    @api servicePointRetrievedData = {};
    fieldsDataRaw = '';
    fieldsDataReqRaw = '';
    customSettings;
    @track newServicePoint;
    validForm = true;
    verifyAddressDisabledOnUpdate = true;
    @api theRecord = [];
    @api rowsplitele = [];
    @api rowsplitgas = [];
    @api rowsplitacqua = [];
    @api rowsplitambiente = [];
    @api responseArriccData;
    isSap = false;
    isValid = false;
    isValidFields = false;
    @api isricercainsap;
    @api recordDistributorPointCode;
    @api selectedDistributor;
    isDistributor = false;
    booleanFormDistributor = false;
    @api retrievedDistributor = {};
    @api commodity = '';
    @api processtype;
    @track oldSupplyType = '';
    @track spCodeChanged = false;

    @track recordTypeId;
    @track existsServicePoint = false;
    callWinBack = false;
    managedMeterClass = ['10 x 30 - 10 mc', '20 x 40 - 16 mc', '3 x 15 - 2.5 mc', '5 x 20 - 4 mc', '7 x 25 - 6.3 mc', 'WV 100 - 100 mc', 'WV 50 - 25 mc', 'WV 80 - 63 mc', 'WV150 - 300 mc'];
    
    /**
     * Handle save button availability
     */
    get saveBtnDisabled() {
        if ((this.selectedservicepoint != undefined && this.verifyAddressDisabledOnUpdate) || this.selectedservicepoint != undefined && !this.verifyAddressDisabledOnUpdate && this.hasAddressBeenVerified) {
            return false;
        }
        else {
            return false;
        }
    }

    /**
     * Verify address data
     */
    handleAddressVerification(event) {
        this.hasAddressBeenVerified = event.detail;
    }
    @api
    saveWrapObject(wrapObjectInput) {
        this.wrapObjectInput = wrapObjectInput;
    }

    /**
     * Split string and create array of fields
     * @param {*} fieldsDataRaw 
     */
    toArray(fieldsDataRaw) {
        console.log('XXX toArray: fieldsDataRaw -> '+fieldsDataRaw);
        let fieldsData = fieldsDataRaw.split(",");
        let fieldsDataFinal = [];

        for (var i = 0; i < fieldsData.length; i++) {
            if (fieldsData[i] != '') {
                fieldsDataFinal.push(fieldsData[i].trim());
            }
        }

        return fieldsDataFinal;
    }


    fieldRequiredMapping() {

        let mapFieldReq = new Map();

        if ((this.rowsplitele != undefined || this.rowsplitele != '') && this.recordtype.label === 'Punto Elettrico') {
            this.rowsplitele.forEach(element => {
                mapFieldReq.set(element, true);
            });
        }
        else if ((this.rowsplitgas != undefined || this.rowsplitgas != '') && this.recordtype.label === 'Punto Gas') {
            this.rowsplitgas.forEach(element => {
                mapFieldReq.set(element, true);
            });
        }
        else if ((this.rowsplitacqua != undefined || this.rowsplitacqua != '') && this.recordtype.label === 'Punto Idrico') {
            this.rowsplitacqua.forEach(element => {
                mapFieldReq.set(element, true);
            });
        }else if ((this.rowsplitambiente != undefined || this.rowsplitambiente != '') && this.recordtype.label === 'Punto Ambiente') {
            this.rowsplitambiente.forEach(element => {
                mapFieldReq.set(element, true);
            });
        }
        return mapFieldReq;
    }

    /**
     * Form array of field objects
     * @param {*} fieldsData 
     * @param {*} fieldsDataReq 
     */
    toObject(fieldsData, fieldsDataReq) {

        let fieldsDataObject = [];
        let mapFieldReq = new Map();
        mapFieldReq = this.fieldRequiredMapping();
        var fieldReqParse = fieldsDataReq.toString();
        let fieldReq = fieldReqParse.split(",");
        console.log('### this.fieldsData --> ' + fieldsData)
        fieldsDataReq.forEach(element => {
            console.log('XXX toObject: this.fieldsDataReq -> '+fieldsDataReq);
            mapFieldReq.set(element, true);
        });
        console.log('XXX toObject: this.selectedservicepoint -> '+this.selectedservicepoint);
        console.log('XXX toObject: this.processtype -> '+this.processtype);
        console.log('XXX toObject: this.recordtype.label -> '+this.recordtype.label);
        fieldsData.forEach(element => {
            console.log('XXX toObject: this.element -> '+element);
            if (this.selectedservicepoint != undefined && this.processtype == '') {
                if (element == 'CommoditySector__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: this.servicePointRetrievedData[element],
                            disabled: true
                        }
                    )
                }
                else if ((element == 'DisconnectibilityType__c' && this.servicePointRetrievedData['Disconnectable__c'] == 'SI')) {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: '',
                            disabled: true
                        }
                    )
                }
                else if (element == 'SAPImplantCode__c' || element == 'IsRemoteManaged__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: this.servicePointRetrievedData[element],
                            disabled: true
                        }
                    )
                }
                else if (element == 'Resident__c') {
                    let resValue =  this.allSubmitedFields[element] !== null && this.allSubmitedFields[element] !== undefined ? this.allSubmitedFields[element] : 
                                    this.servicePointRetrievedData[element] ? this.servicePointRetrievedData[element] 
                                    : false;
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: false,
                            value: resValue,
                            disabled: false
                        }
                    )
                }
                else if (element == 'SAPImplantCode__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: this.servicePointRetrievedData[element],
                            disabled: true
                        }
                    )
                }
                else if (element == 'MeterStatus__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: this.servicePointRetrievedData[element],
                            disabled: true
                        }
                    )
                }
                else if (this.recordtype.label === 'Punto Elettrico' && element === 'PlugPresence__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: this.servicePointRetrievedData[element],
                            disabled: false
                        }
                    )
                }
                else if (this.recordtype.label === 'Punto Gas' && element === 'PlugPresence__c') {
                }
                else if (element == 'PowerRequested__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: this.servicePointRetrievedData[element],
                            disabled: this.allSubmitedFields['PlugPresence__c'] == 'No'? true : false
                        }
                    )
                }
                else if (element == 'Distributor__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: this.servicePointRetrievedData[element],
                            disabled: true
                        }
                    )
                }
                else if (this.recordtype.label === 'Punto Idrico' && element === 'ServicePointCode__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: false,
                            value: this.servicePointRetrievedData[element],
                            disabled: true
                        }
                    )
                }
                else if (this.recordtype.label === 'Punto Idrico' && element === 'ImplantType__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: true,
                            value: this.servicePointRetrievedData[element],
                            disabled: false
                        }
                    )
                }
                else if (this.recordtype.label === 'Punto Idrico' && element === 'SupplyType__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: true,
                            value: this.isSap ? '' : this.servicePointRetrievedData[element],
                            disabled: false
                        }
                    )
                }
                else if (this.recordtype.label === 'Punto Idrico' && element === 'MarketOrigin__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: true,
                            value: 'Regolamentato',
                            disabled: false
                        }
                    )
                }
                else if (this.recordtype.label === 'Punto Idrico' && element === 'ATO__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: true,
                            value: this.servicePointRetrievedData[element],
                            disabled: true
                        }
                    )
                }
                else if(this.recordtype.label === 'Punto Idrico' && element === 'ServicePointCode__c'){
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: false,
                            value: this.allSubmitedFields['ServicePointCode__c'],
                            disabled: true
                        }
                    )
                }
                else if(this.recordtype.label === 'Punto Idrico' && element === 'PlugPresence__c'){
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: true,
                            value: this.servicePointRetrievedData[element],
                            disabled: false
                        }
                    )
                }
                else {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: this.servicePointRetrievedData[element],
                            disabled: element == ('ServicePointCode__c') ? true : false
                        }
                    )
                }
            }
            else if (this.selectedservicepoint != undefined && this.processtype != '') {
                if ((element == 'DisconnectibilityType__c' && this.servicePointRetrievedData['Disconnectable__c'] == 'SI')) {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: '',
                            disabled: true
                        }
                    )
                }
                else {
                    if (location.href.includes('HDT_FL_PostSalesMasterDispatch')) {
                        fieldsDataObject.push(
                            {
                                fieldname: element,
                                required: mapFieldReq.get(element),
                                value: this.servicePointRetrievedData[element],
                                disabled: !(this.servicePointRetrievedData[element] == null && mapFieldReq.get(element))
                            } 
                        )
                    }
                    else {
                        var readonlyfields = ['CommoditySector__c','ServicePointCode__c','SAPImplantCode__c','MeterStatus__c'];
                        fieldsDataObject.push(
                            {
                                fieldname: element,
                                required: mapFieldReq.get(element),
                                value: this.servicePointRetrievedData[element],
                                disabled: readonlyfields.includes(element) ? true : false
                            }
                        )
                    }

                }
            }
            else {
                if ((this.recordtype.label == 'Punto Elettrico' && element == 'CommoditySector__c')) {

                    this.commodity = 'Energia Elettrica';
                    this.allSubmitedFields.CommoditySector__c = 'Energia Elettrica';

                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: 'Energia Elettrica',
                            disabled: true
                        }
                    )
                } 
                else if ((this.recordtype.label === 'Punto Elettrico' || this.recordtype.label === 'Punto Gas' || this.recordtype.label === 'Punto Idrico' || this.recordtype.label === 'Punto Ambiente' ) && element === 'SAPImplantCode__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: this.servicePointRetrievedData[element],
                            disabled: true
                        }
                    )
                }
                else if (this.recordtype.label === 'Punto Gas' && element === 'CommoditySector__c') {
                    this.commodity = 'Gas';
                    this.allSubmitedFields.CommoditySector__c = 'Gas';
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: 'Gas',
                            disabled: true
                        }
                    )
                }
                else if (this.recordtype.label === 'Punto Gas' && element === 'Pressure__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: this.servicePointRetrievedData[element],
                            disabled: true
                        }
                    )
                }
                else if (element === 'RemiCode__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: this.servicePointRetrievedData[element],
                            disabled: true
                        }
                    )
                }
                else if (this.recordtype.label === 'Punto Elettrico' && element === 'PlugPresence__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: this.servicePointRetrievedData[element],
                            disabled: false
                        }
                    )
                }
                else if (this.recordtype.label === 'Punto Gas' && element === 'PlugPresence__c') {
                }
                else if (element == 'PowerRequested__c') {

                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: this.servicePointRetrievedData[element],
                            disabled: this.allSubmitedFields['PlugPresence__c'] == 'No'? true : false
                        }
                    )
                }
                else if (element === 'MeterSN__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: this.servicePointRetrievedData[element],
                            disabled: true
                        }
                    )
                }
                else if (this.recordtype.label === 'Punto Gas' && element === 'ImplantType__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: true,
                            value: this.servicePointRetrievedData[element],
                            disabled: false
                        }
                    )
                }
                else if (element === 'Resident__c') {
                    let residentValue = this.allSubmitedFields[element] ? this.allSubmitedFields[element] : false;                 
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: false,
                            value: residentValue,
                            disabled: false
                        }
                    )        
                }
                else if (this.recordtype.label === 'Punto Idrico' && element === 'ImplantType__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: true,
                            value: this.servicePointRetrievedData[element],
                            disabled: false
                        }
                    )
                }
                else if (this.recordtype.label === 'Punto Idrico' && element === 'SupplyType__c') {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: true,
                            value: this.isSap ? '' : this.servicePointRetrievedData[element],
                            disabled: false
                        }
                    )
                }
                else if (this.recordtype.label === 'Punto Idrico' && element === 'CommoditySector__c') {
                    this.commodity = 'Acqua';
                    this.allSubmitedFields.CommoditySector__c = 'Acqua';
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: 'Acqua',
                            disabled: true
                        }
                    )
                }

                else if (this.recordtype.label === 'Punto Idrico' && element == 'ATO__c') {

                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: this.servicePointRetrievedData[element],
                            disabled: true
                        }
                    )
                }
                else if(this.recordtype.label === 'Punto Idrico' && element === 'MarketOrigin__c'){
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: false,
                            value: 'Regolamentato',
                            disabled: false
                        }
                    )
                }
                else if(this.recordtype.label === 'Punto Ambiente' && element === 'SubscriberCustomerCode__c'){
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: false,
                            value: this.customercode,
                            disabled: true
                        }
                    )
                }               
                else if (this.recordtype.label === 'Punto Ambiente' && element === 'CommoditySector__c') {
                    this.commodity = 'Ambiente';
                    this.allSubmitedFields.CommoditySector__c = 'Ambiente';
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: 'Ambiente',
                            disabled: true
                        }
                    )
                }
                else if ((this.recordtype.label === 'Punto Elettrico' || this.recordtype.label === 'Punto Gas' || this.recordtype.label === 'Punto Idrico' || this.recordtype.label === 'Punto Ambiente') && element === 'MeterStatus__c') {
                    this.allSubmitedFields.MeterStatus__c = 'Bozza';
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: 'Bozza',
                            disabled: true
                        }
                    )
                }
                else if ((this.recordtype.label === 'Punto Elettrico' || this.recordtype.label === 'Punto Gas' || this.recordtype.label === 'Punto Idrico' || this.recordtype.label === 'Punto Ambiente') && element === 'Distributor__c'){
                    this.allSubmitedFields.Distributor__c = this.recordDistributorPointCode;
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: this.recordDistributorPointCode,
                            disabled: true
                        }
                    )
                    this.isDistributor = false;
                }
                else if(this.recordtype.label === 'Punto Elettrico' && element === 'ServicePointCode__c' && this.allSubmitedFields['PlugPresence__c'] == 'No'){
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: false,
                            value: this.allSubmitedFields['ServicePointCode__c'],
                            disabled: false
                        }
                    )
                }
                else if(this.recordtype.label === 'Punto Idrico' && element === 'ServicePointCode__c'){
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: false,
                            value: this.allSubmitedFields['ServicePointCode__c'],
                            disabled: true
                        }
                    )
                }
                else if(this.recordtype.label === 'Punto Idrico' && element === 'PlugPresence__c'){
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: true,
                            value: '',
                            disabled: false
                        }
                    )
                }
                else {
                    fieldsDataObject.push(
                        {
                            fieldname: element,
                            required: mapFieldReq.get(element),
                            value: '',
                            disabled: false
                        }
                    )
                }
            }
        });
        let accountIndex = fieldsDataObject.findIndex(el => el.fieldname === 'Account__c');
        if(accountIndex > -1)
        {
            fieldsDataObject[accountIndex].required = false;
            fieldsDataObject[accountIndex].disabled = true;
        }
        return fieldsDataObject;
    }

    toObjectAddressInit(data) {

        let fieldsDataObject = [];
        Object.keys(data).forEach(keys => {
            fieldsDataObject.push(
                {
                    fieldname: keys,
                    required: false,
                    value: '',
                    disabled: false
                }
            )
        });
        return fieldsDataObject;
    }

    handleCallServiceSap(selectedservicepoint) {
        let codicePunto = selectedservicepoint.ServicePointCode__c;
        let codiceImpianto = selectedservicepoint.SAPImplantCode__c;
        let codiceContratto = selectedservicepoint.SAPContractCode__c;
        let commoditySector = selectedservicepoint.CommoditySector__c;

        console.log('XXX handleCallServiceSap: codicePunto     -> '+codicePunto);
        console.log('XXX handleCallServiceSap: codiceImpianto  -> '+codiceImpianto);
        console.log('XXX handleCallServiceSap: codiceContratto -> '+codiceContratto);
        console.log('XXX handleCallServiceSap: commoditySector -> '+commoditySector);
        
        /*let servicePointCode;
        let spCode = JSON.stringify(selectedservicepoint).split(',');
        spCode.forEach(element => {
            if (element.split(':')[0].includes('Codice Punto')) {
                servicePointCode = element.split(':')[1];
            }
            if (element.split(':')[0].includes('ServicePointCode__c')) {
                servicePointCode = element.split(':')[1];
            }
        });
        let lenght = servicePointCode !== undefined ? servicePointCode.length : 0;
        let input = '';
        if (selectedservicepoint['Codice Punto'] == undefined && lenght > 0) {
            input = servicePointCode.substring(1, lenght - 1);
        }
        else {
            input = selectedservicepoint['Codice Punto'];
        }
        let sp = selectedservicepoint;
        let implantCode = selectedservicepoint['Impianto SAP'] !== null && selectedservicepoint['Impianto SAP'] !== undefined ? selectedservicepoint['Impianto SAP'].length === 10 && selectedservicepoint['Impianto SAP'].startsWith("4") ? selectedservicepoint['Impianto SAP']:'' : '';
        
        console.log('XXX selectedservicepoint[Impianto SAP]: '+selectedservicepoint['Impianto SAP']);
        console.log('XXX selectedservicepoint[Codice Punto]: '+selectedservicepoint['Codice Punto']);
        console.log('XXX servicePointCode: '+servicePointCode);
        console.log('XXX selectedservicepoint: '+JSON.stringify(selectedservicepoint));
        console.log('XXX pod: '+input+'| impianto: '+implantCode);*/
        
        callService({ contratto: codiceContratto, pod: codicePunto, impianto: codiceImpianto }).then(data => {
            if (data.statusCode == '200') {
                this.callWinBack = true;
                this.responseArriccData = data;
                console.log('XXX callService: responseArriccData -->'+JSON.stringify(data));
                if (this.servicePointRetrievedData == undefined) {
                    extractDataFromArriccDataServiceWithExistingSp({ sp: sp, response: data }).then(datas => {
                        console.log('XXX servicePointRetrievedData == undefined: datas[0] -> '+JSON.stringify(datas[0]));
                        this.isSap = true;
                        this.servicePointRetrievedData = datas[0];
                        this.oldSupplyType = datas[0].SupplyType__c;

                        switch (this.servicePointRetrievedData['CommoditySector__c']) {
                            case 'Energia Elettrica':
                                this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldEle__c : (this.customSettings.FieldEle__c == null || this.customSettings.FieldEle__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldEle__c));
                                this.fieldsDataReqRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldRequiredEle__c : (this.customSettings.FieldRequiredEle__c == null || this.customSettings.FieldRequiredEle__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldRequiredEle__c));
                                break;
                            case 'Gas':
                                this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldGas__c : (this.customSettings.FieldGas__c == null || this.customSettings.FieldGas__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldGas__c));
                                this.fieldsDataReqRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldRequiredGas__c : (this.customSettings.FieldRequiredGas__c == null || this.customSettings.FieldRequiredGas__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldRequiredGas__c));
                                break;
                            case 'Acqua':
                                //this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldWater__c : (this.customSettings.FieldWater__c == null || this.customSettings.FieldWater__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldWater__c));
                                //this.fieldsDataReqRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldRequiredWater__c : (this.customSettings.FieldRequiredWater__c == null || this.customSettings.FieldRequiredWater__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldRequiredWater__c));
                                this.fieldsDataRaw = this.customSettings.FieldWater__c + ',' + this.customSettings.FieldsWaterExtended__c;
                                this.fieldsDataReqRaw = this.customSettings.FieldRequiredWater__c;
                                break;
                            case 'Ambiente':
                                this.fieldsDataRaw = (this.customSettings.FieldWaste__c !== null && this.customSettings.FieldWaste__c !== undefined ? this.customSettings.FieldWaste__c : null);
                                this.fieldsDataReqRaw = (this.customSettings.FieldRequiredWaste__c !== null && this.customSettings.FieldRequiredWaste__c !== undefined ? this.customSettings.FieldRequiredWaste__c : null);
                                break;
                        }

                        this.fieldsData = this.toArray(this.fieldsDataRaw);
                        this.fieldsDataReq = this.toArray(this.fieldsDataReqRaw);
                        this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);
                        this.template.querySelector("c-hdt-target-object-address-fields").handleAddressValuesIfSap(this.servicePointRetrievedData);
                        this.getInstanceWrapObject(this.servicePointRetrievedData);
                    });
                }
                else {
                    extractDataFromArriccDataServiceWithExistingSp({ sp: this.servicePointRetrievedData, response: data }).then(datas => {
                        console.log('XXX servicePointRetrievedData != undefined: datas[0] -> '+JSON.stringify(datas[0]));
                        this.servicePointRetrievedData = datas[0];
                        this.oldSupplyType = datas[0].SupplyType__c;

                        switch (this.servicePointRetrievedData['CommoditySector__c']) {
                            case 'Energia Elettrica':
                                this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldEle__c : (this.customSettings.FieldEle__c == null || this.customSettings.FieldEle__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldEle__c));
                                this.fieldsDataReqRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldRequiredEle__c : (this.customSettings.FieldRequiredEle__c == null || this.customSettings.FieldRequiredEle__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldRequiredEle__c));
                                break;
                            case 'Gas':
                                this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldGas__c : (this.customSettings.FieldGas__c == null || this.customSettings.FieldGas__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldGas__c));
                                this.fieldsDataReqRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldRequiredGas__c : (this.customSettings.FieldRequiredGas__c == null || this.customSettings.FieldRequiredGas__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldRequiredGas__c));
                                break;
                            case 'Acqua':
                                //this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldWater__c : (this.customSettings.FieldWater__c == null || this.customSettings.FieldWater__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldWater__c));
                                //this.fieldsDataReqRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldRequiredWater__c : (this.customSettings.FieldRequiredWater__c == null || this.customSettings.FieldRequiredWater__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldRequiredWater__c));
                                this.fieldsDataRaw = this.customSettings.FieldWater__c + ',' + this.customSettings.FieldsWaterExtended__c;
                                this.fieldsDataReqRaw = this.customSettings.FieldRequiredWater__c;
                                break;
                            case 'Ambiente':
                                this.fieldsDataRaw = (this.customSettings.FieldWaste__c !== null && this.customSettings.FieldWaste__c !== undefined ? this.customSettings.FieldWaste__c : null);
                                this.fieldsDataReqRaw = (this.customSettings.FieldRequiredWaste__c !== null && this.customSettings.FieldRequiredWaste__c !== undefined ? this.customSettings.FieldRequiredWaste__c : null);
                                break;
                        }

                        this.fieldsData = this.toArray(this.fieldsDataRaw);
                        this.fieldsDataReq = this.toArray(this.fieldsDataReqRaw);
                        this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);
                        this.template.querySelector("c-hdt-target-object-address-fields").handleAddressValuesIfSap(this.servicePointRetrievedData);

                        this.getInstanceWrapObject(this.servicePointRetrievedData);
                    });
                }
            }
            else {
                this.isSap = false;
            }
        });
    }

    /**
     * Organize fields data
     */
    manageFields() {
        //get main data fields

        this.fieldsData = this.toArray(this.fieldsDataRaw);
        this.fieldsDataReq = this.toArray(this.fieldsDataReqRaw);
        this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);

        //get address fields
        this.fieldsAddress = this.toArray(this.customSettings.FieldAddress__c);
        this.fieldsAddressReq = this.toArray(this.customSettings.FieldRequiredAddress__c);

        //merge all fields together
        this.allFieldsData = this.fieldsData.concat(this.fieldsAddress);
        this.allFieldsDataReq = this.fieldsDataReq.concat(this.fieldsAddressReq);
        this.allFieldsObject = this.toObject(this.allFieldsData, this.allFieldsDataReq);
        console.log('@@1 this.allFieldsData' + this.allFieldsData);
        console.log('@@2 this.allFieldsDataReq' +this.allFieldsDataReq);
    }

    connectedCallback() {
        this.loading = true;

        getCustomSettings().then(data => {
            
            //get data fields based on recordtype label
            if (this.recordtype.label != undefined) {
                console.log('XXX RecordType >>> ' + JSON.stringify(this.recordtype));
                switch (this.recordtype.label) {
                    case 'Punto Elettrico':
                        console.log('XXX Inside RecordTypeSwitch Ele');
                        this.fieldsDataRaw = (data.FieldGeneric__c == null || data.FieldGeneric__c == undefined ? data.FieldEle__c : (data.FieldEle__c == null || data.FieldEle__c == null ? data.FieldGeneric__c : data.FieldGeneric__c + ',' + data.FieldEle__c));
                        this.fieldsDataReqRaw = (data.Field_Required_Generic__c == null || data.Field_Required_Generic__c == undefined ? data.FieldRequiredEle__c : (data.FieldRequiredEle__c == null || data.FieldRequiredEle__c == null ? data.Field_Required_Generic__c : data.Field_Required_Generic__c + ',' + data.FieldRequiredEle__c));
                        break;
                    case 'Punto Gas':
                        console.log('XXX Inside RecordTypeSwitch Gas');
                        this.fieldsDataRaw = (data.FieldGeneric__c == null || data.FieldGeneric__c == undefined ? data.FieldGas__c : (data.FieldGas__c == null || data.FieldGas__c == null ? data.FieldGeneric__c : data.FieldGeneric__c + ',' + data.FieldGas__c));
                        this.fieldsDataReqRaw = (data.Field_Required_Generic__c == null || data.Field_Required_Generic__c == undefined ? data.FieldRequiredGas__c : (data.FieldRequiredGas__c == null || data.FieldRequiredGas__c == null ? data.Field_Required_Generic__c : data.Field_Required_Generic__c + ',' + data.FieldRequiredGas__c));
                        break;
                    case 'Punto Idrico':
                        //this.fieldsDataRaw = (data.FieldGeneric__c == null || data.FieldGeneric__c == undefined ? data.FieldWater__c : (data.FieldWater__c == null || data.FieldWater__c == null ? data.FieldGeneric__c : data.FieldGeneric__c + ',' + data.FieldWater__c));
                        this.fieldsDataRaw = data.FieldWater__c + ',' + data.FieldsWaterExtended__c;
                        //this.fieldsDataReqRaw = (data.Field_Required_Generic__c == null || data.Field_Required_Generic__c == undefined ? data.FieldRequiredWater__c : (data.FieldRequiredWater__c == null || data.FieldRequiredWater__c == null ? data.Field_Required_Generic__c : data.Field_Required_Generic__c + ',' + data.FieldRequiredWater__c));
                        this.fieldsDataReqRaw = data.FieldRequiredWater__c;
                        break;
                    case 'Punto Ambiente':
                        this.fieldsDataRaw = (data.FieldWaste__c !== null && data.FieldWaste__c !== undefined ? data.FieldWaste__c:null);
                        this.fieldsDataReqRaw = (data.FieldRequiredWaste__c !== null && data.FieldRequiredWaste__c !== undefined ? data.FieldRequiredWaste__c:null);
                        break;
                    }
            }

            this.customSettings = data;
            console.log('# CustomSettings >>> ' + JSON.stringify(this.customSettings));
            if (this.selectedservicepoint != undefined) {

                this.fieldsDataRaw = 'RecordTypeId, RecordType.DeveloperName, ' + data.FieldEle__c + ', ' + data.FieldGas__c + ',' + data.FieldWater__c + ', ' + data.FieldWaste__c + ',' + data.FieldGeneric__c;
                this.fieldsDataReqRaw = data.FieldRequiredEle__c + ', ' + data.FieldRequiredGas__c + ',' + data.FieldRequiredWater__c + ', ' + data.FieldRequiredWaste__c + ',' + data.Field_Required_Generic__c;

                let queryFields = [...new Set(this.toArray(this.fieldsDataRaw + ', ' + this.customSettings.FieldAddress__c))];
                /** Casistica service point esistente su SAP */
                if(Array.isArray(this.selectedservicepoint))
                {
                    this.callWinBack = true;
                    this.servicePointRetrievedData = this.selectedservicepoint[0];
                    this.recordTypeId = this.servicePointRetrievedData['RecordTypeId'];
                    let recordtype = {};
                    if (this.servicePointRetrievedData.CommoditySector__c != undefined) {
                        console.log('### ServicePointRetrievedData >>> ' + JSON.stringify(this.servicePointRetrievedData));
                        console.log('### CommoditySector >>>' + this.servicePointRetrievedData.CommoditySector__c)
                        switch (this.servicePointRetrievedData.CommoditySector__c) {
                            case 'Energia Elettrica':
                                recordtype['label'] = 'Punto Ele';
                                recordtype['value'] = this.servicePointRetrievedData['RecordTypeId'];
                                recordtype['DeveloperName'] = 'HDT_RT_Ele';
                                this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldEle__c : (this.customSettings.FieldEle__c == null || this.customSettings.FieldEle__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldEle__c));
                                this.fieldsDataReqRaw = (this.customSettings.Field_Required_Generic__c == null || this.customSettings.Field_Required_Generic__c == undefined ? this.customSettings.FieldRequiredEle__c : (this.customSettings.FieldRequiredEle__c == null || this.customSettings.FieldRequiredEle__c == null ? this.customSettings.Field_Required_Generic__c : this.customSettings.Field_Required_Generic__c + ',' + this.customSettings.FieldRequiredEle__c));
                                break;
                            case 'Gas':
                                recordtype['label'] = 'Punto Gas';
                                recordtype['value'] = this.servicePointRetrievedData['RecordTypeId'];
                                recordtype['DeveloperName'] = 'HDT_RT_Gas';
                                console.log('### Inside Gas Switch');
                                this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldGas__c : (this.customSettings.FieldGas__c == null || this.customSettings.FieldGas__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldGas__c));
                                this.fieldsDataReqRaw = (this.customSettings.Field_Required_Generic__c == null || this.customSettings.Field_Required_Generic__c == undefined ? this.customSettings.FieldRequiredGas__c : (this.customSettings.FieldRequiredGas__c == null || this.customSettings.FieldRequiredGas__c == null ? this.customSettings.Field_Required_Generic__c : this.customSettings.Field_Required_Generic__c + ',' + this.customSettings.FieldRequiredGas__c));
                                break;
                            case 'Acqua':
                                recordtype['label'] = 'Punto Idrico';
                                recordtype['value'] = this.servicePointRetrievedData['RecordTypeId'];
                                recordtype['DeveloperName'] = 'HDT_RT_Acqua';
                                //this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldWater__c : (this.customSettings.FieldWater__c == null || this.customSettings.FieldWater__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldWater__c));
                                console.log('@@ACQUA');
                                this.fieldsDataRaw = this.customSettings.FieldWater__c + ',' + this.customSettings.FieldsWaterExtended__c;
                                this.fieldsDataReqRaw = this.customSettings.FieldRequiredWater__c;
                                //this.fieldsDataReqRaw = (this.customSettings.Field_Required_Generic__c == null || this.customSettings.Field_Required_Generic__c == undefined ? this.customSettings.FieldRequiredWater__c : (this.customSettings.FieldRequiredWater__c == null || this.customSettings.FieldRequiredWater__c == null ? this.customSettings.Field_Required_Generic__c : this.customSettings.Field_Required_Generic__c + ',' + this.customSettings.FieldRequiredWater__c));
                                break;
                            case 'Ambiente':
                                recordtype['label'] = 'Punto Ambiente';
                                recordtype['value'] = this.servicePointRetrievedData['RecordTypeId'];
                                recordtype['DeveloperName'] = 'HDT_RT_Ambiente';
                                this.fieldsDataRaw = (this.customSettings.FieldWaste__c !== null && this.customSettings.FieldWaste__c !== undefined ? this.customSettings.FieldWaste__c:null);
                                this.fieldsDataReqRaw = (this.customSettings.FieldRequiredWaste__c !== null && this.customSettings.FieldRequiredWaste__c !== undefined ? this.customSettings.FieldRequiredWaste__c:null);
                                break;
                            }
                    }
                    this.recordtype = {...recordtype};
                    this.manageFields();
                    this.getInstanceWrapObject(this.servicePointRetrievedData);
                }
                else
                {
                    console.log('## this.selectedservicepoint ' + JSON.stringify(this.selectedservicepoint));
                    let implantCode = this.selectedservicepoint['Impianto SAP'] !== null && this.selectedservicepoint['Impianto SAP'] == undefined? this.selectedservicepoint['Impianto SAP']:'';
                    let codeToSearch = this.selectedservicepoint['Codice Punto'] !== null && this.selectedservicepoint['Codice Punto'] !== undefined? this.selectedservicepoint['Codice Punto']:implantCode;
                    /** Casistica service point esistente su SFDC */
                    if(!codeToSearch)
                    {
                        codeToSearch = this.selectedservicepoint['ServicePointId'];
                    }
                    getServicePoint({ code: codeToSearch, fields: queryFields.join() }).then(data => {
                        console.log('XXX getServicePoint data: '+JSON.stringify(data));
                        this.handleCallServiceSap(data[0]);
                        this.existsServicePoint = true;
                        this.servicePointRetrievedData = data[0];
                        this.recordTypeId = this.servicePointRetrievedData['RecordTypeId'];
                        let recordtype = {};
                        if (this.servicePointRetrievedData.RecordType.DeveloperName != undefined) {
                            switch (this.servicePointRetrievedData.RecordType.DeveloperName) {
                                case 'HDT_RT_Ele':
                                    recordtype['label'] = 'Punto Ele';
                                    recordtype['value'] = this.servicePointRetrievedData['RecordTypeId'];
                                    recordtype['DeveloperName'] = 'HDT_RT_Ele';
                                    this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldEle__c : (this.customSettings.FieldEle__c == null || this.customSettings.FieldEle__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldEle__c));
                                    this.fieldsDataReqRaw = (this.customSettings.Field_Required_Generic__c == null || this.customSettings.Field_Required_Generic__c == undefined ? this.customSettings.FieldRequiredEle__c : (this.customSettings.FieldRequiredEle__c == null || this.customSettings.FieldRequiredEle__c == null ? this.customSettings.Field_Required_Generic__c : this.customSettings.Field_Required_Generic__c + ',' + this.customSettings.FieldRequiredEle__c));
                                    break;
                                case 'HDT_RT_Gas':
                                    recordtype['label'] = 'Punto Gas';
                                    recordtype['value'] = this.servicePointRetrievedData['RecordTypeId'];
                                    recordtype['DeveloperName'] = 'HDT_RT_Gas';
                                    this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldGas__c : (this.customSettings.FieldGas__c == null || this.customSettings.FieldGas__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldGas__c));
                                    this.fieldsDataReqRaw = (this.customSettings.Field_Required_Generic__c == null || this.customSettings.Field_Required_Generic__c == undefined ? this.customSettings.FieldRequiredGas__c : (this.customSettings.FieldRequiredGas__c == null || this.customSettings.FieldRequiredGas__c == null ? this.customSettings.Field_Required_Generic__c : this.customSettings.Field_Required_Generic__c + ',' + this.customSettings.FieldRequiredGas__c));
                                    break;
                                case 'HDT_RT_Acqua':
                                    recordtype['label'] = 'Punto Idrico';
                                    recordtype['value'] = this.servicePointRetrievedData['RecordTypeId'];
                                    recordtype['DeveloperName'] = 'HDT_RT_Acqua';
                                    //this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldWater__c : (this.customSettings.FieldWater__c == null || this.customSettings.FieldWater__c == null ? this.customSettings.FieldGeneric__c : this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldWater__c));
                                    //this.fieldsDataReqRaw = (this.customSettings.Field_Required_Generic__c == null || this.customSettings.Field_Required_Generic__c == undefined ? this.customSettings.FieldRequiredWater__c : (this.customSettings.FieldRequiredWater__c == null || this.customSettings.FieldRequiredWater__c == null ? this.customSettings.Field_Required_Generic__c : this.customSettings.Field_Required_Generic__c + ',' + this.customSettings.FieldRequiredWater__c));
                                    console.log('@@ACQUA_2');
                                    this.fieldsDataRaw = this.customSettings.FieldWater__c + ',' + this.customSettings.FieldsWaterExtended__c;
                                    this.fieldsDataReqRaw = this.customSettings.FieldRequiredWater__c;
                                    break;
                                case 'HDT_RT_Ambiente':
                                    recordtype['label'] = 'Punto Ambiente';
                                    recordtype['value'] = this.servicePointRetrievedData['RecordTypeId'];
                                    recordtype['DeveloperName'] = 'HDT_RT_Ambiente';
                                    this.fieldsDataRaw = (this.customSettings.FieldWaste__c !== null && this.customSettings.FieldWaste__c !== undefined ? this.customSettings.FieldWaste__c:null);
                                    this.fieldsDataReqRaw = (this.customSettings.FieldRequiredWaste__c !== null && this.customSettings.FieldRequiredWaste__c !== undefined ? this.customSettings.FieldRequiredWaste__c:null);
                                    break;
                            }
                        }
                        this.recordtype = {...recordtype};
                        this.manageFields();
                        this.getInstanceWrapObject(this.servicePointRetrievedData);
                    }).catch(error => {
                        const toastErrorMessage = new ShowToastEvent({
                            title: 'Errore',
                            message: error.message,
                            variant: 'error'
                        });
                        this.dispatchEvent(toastErrorMessage);
                    });
                }
            }
            else {
                this.manageFields();
            }
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
    getInstanceWrapObject(servicePointRetrievedData) {
        this.allSubmitedFields = {...servicePointRetrievedData};
        this.allSubmitedFields.PowerRequested__c = null;
        console.log('### AddressSObject >>> ' + JSON.stringify(this.allSubmitedFields));
        getInstanceWrapAddressObject({ servicePoint: JSON.stringify(this.allSubmitedFields) }).then(data => {
            console.log('### Address Data >>> ' + JSON.stringify(data));
            this.template.querySelector("c-hdt-target-object-address-fields").handleAddressValues(data);
        });
    }


    /**
     * Pre-fill Account__c field on render
     */
    renderedCallback() {
        if (this.fieldsReady) {
            if (this.selectedservicepoint == undefined) {
                let accountField = this.template.querySelector('[data-name="Account__c"]');
                if (accountField != null || accountField != undefined) {
                    accountField.value = this.accountid;
                }
            }
        }
    }

    /**
     * Reset fields loading when closing modal
     */
    disconnectedCallback() {
        this.fieldsReady = false;
    }

    /**
     * Handle fill fields button availability
     * @param {*} fieldName
     * @param {*} fieldValue
     */
    handleFillFieldsButtonAvailability(fieldName, fieldValue) {
        if (fieldName == 'ServicePointCode__c') {
            this.servicePointCode = fieldValue;
            if (this.servicePointCode.length > 13 && this.selectedservicepoint == undefined) {
                this.fillFieldsDataDisabled = false;
            }
            else {
                this.fillFieldsDataDisabled = true;
            }
        }
    }

    /**
     * Get fields value
     * @param {*} event 
     */
    handleFieldsDataChange(event) {

        this.handleFillFieldsButtonAvailability(event.target.fieldName, event.target.value);
        this.allSubmitedFields[event.target.fieldName] = event.target.value;
        this.validForm = true;

        if (event.target.fieldName == 'Disconnectable__c' && event.target.value == 'SI') {
            this.servicePointRetrievedData.Disconnectable__c = 'SI';
            this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);
        }
        if (event.target.fieldName == 'Distributor__c') {
            this.recordDistributorPointCode = event.target.value;
            this.fieldsData['Distributor__c'] = event.target.value;
        }
        if (event.target.fieldName == 'Disconnectable__c' && event.target.value == 'NO') {
            this.servicePointRetrievedData.Disconnectable__c = 'NO';
            this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);
        }
        //25/08/2021 - gabriele.rota@webresults.it - Switch Flag Resident in base a Tipo Fornitura
        if (event.target.fieldName == 'SupplyType__c') {
            this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);
        }
        if (event.target.fieldName == 'ServicePointCode__c') {
            this.allSubmitedFields[event.target.fieldName] = event.target.value?.toUpperCase();
            this.spCodeChanged = true;
        }
        if (event.target.fieldName == 'PlugPresence__c') {
            this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);
        }
    }

    /**
     * Handle main data fields filling request
     */
    handleDataFieldsFilling() {
        this.hasDataBeenFilled = true;
    }

    /**
     * Close create form
     */
    closeCreateTargetObjectModal() {
        this.dispatchEvent(new CustomEvent('closecreateform'));
    }

    /**
     * Get submited address fields values
     * @param {*} event 
     */
    getSubmitedAddressFields(event) {
        this.submitedAddressFields = event.detail;
        this.validForm = true;
    }

    /**
     * Check validity before saving
     */
    validationChecks() {

        if (this.selectedservicepoint != undefined) {
            let supplyObject = {...this.allSubmitedFields};
            let servicePointSupply = {...this.servicePointRetrievedData};
            if (Object.keys(this.allSubmitedFields).length != 0) {
                for (var key in supplyObject) {
                    servicePointSupply[key] = supplyObject[key];
                }
            }
            supplyObject = servicePointSupply;
            this.servicePointRetrievedData = servicePointSupply;
            this.allSubmitedFields = supplyObject;
        } 
        else {
            let supplyObject = {...this.allSubmitedFields};
            supplyObject.RecordTypeId = this.recordtype.value;
            supplyObject.Account__c = this.accountid;
            supplyObject.Name = this.servicePointCode;
            this.allSubmitedFields = supplyObject;
        }

        if (this.submitedAddressFields != undefined) {
            let supplyAddressObj = {...this.submitedAddressFields};
            let supplyObject = {...this.allSubmitedFields};
            for (let [key, value] of Object.entries(supplyAddressObj)) {
                supplyObject[key] = value;
            }
            this.allSubmitedFields = supplyObject;
        }
    }

    updateServicePoint() {
        console.log('XXX updateServicePoint: servicePointRetrievedData --> '+JSON.stringify(this.servicePointRetrievedData));
        console.log('XXX updateServicePoint: theRecord --> '+JSON.stringify(this.theRecord));       
        if (this.servicePointRetrievedData != undefined && this.theRecord != undefined) {
            if (this.servicePointRetrievedData['SupplyStreet__c'] != this.theRecord['Via']) {
                this.allSubmitedFields['IsAddressChanged__c'] = true;
                this.servicePointRetrievedData['SupplyStreet__c'] = this.theRecord['Via'];
                this.servicePointRetrievedData['SupplyStreetName__c'] = this.theRecord['Via'];
            }
            if (this.servicePointRetrievedData['SupplyCity__c'] != this.theRecord['Comune'] && this.theRecord['Comune']) {
                this.allSubmitedFields['IsAddressChanged__c'] = true;
                this.servicePointRetrievedData['SupplyCity__c'] = this.theRecord['Comune'];
            }
            if (this.servicePointRetrievedData['SupplyPostalCode__c'] != this.theRecord['CAP']) {
                this.allSubmitedFields['IsAddressChanged__c'] = true;
                this.servicePointRetrievedData['SupplyPostalCode__c'] = this.theRecord['CAP'];
            }
            if (this.servicePointRetrievedData['SupplyCountry__c'] != this.theRecord['Stato']) {
                this.allSubmitedFields['IsAddressChanged__c'] = true;
                this.servicePointRetrievedData['SupplyCountry__c'] = this.theRecord['Stato'];
            }
            if(!this.servicePointRetrievedData['SupplyCountry__c']){
                this.allSubmitedFields['IsAddressChanged__c'] = true;
                this.servicePointRetrievedData['SupplyCountry__c'] = 'ITALIA';
            }
            if (this.servicePointRetrievedData['SupplyProvince__c'] != this.theRecord['Provincia']) {
                this.allSubmitedFields['IsAddressChanged__c'] = true;
                this.servicePointRetrievedData['SupplyProvince__c'] = this.theRecord['Provincia'];
            }
            if (this.servicePointRetrievedData['SupplySAPCityCode__c'] != this.theRecord['Codice Comune SAP'] && this.theRecord['Codice Comune SAP']) {
                this.allSubmitedFields['IsAddressChanged__c'] = true;
                this.servicePointRetrievedData['SupplySAPCityCode__c'] = this.theRecord['Codice Comune SAP'];
            }
            if (this.servicePointRetrievedData['SupplySAPStreetCode__c'] != this.theRecord['Codice Via Stradario SAP'] && this.theRecord['Codice Via Stradario SAP']) {
                this.allSubmitedFields['IsAddressChanged__c'] = true;
                this.servicePointRetrievedData['SupplySAPStreetCode__c'] = this.theRecord['Codice Via Stradario SAP'];
            }
            if (this.servicePointRetrievedData['SupplyStreetNumberExtension__c'] != this.theRecord['Estens.Civico']) {
                this.allSubmitedFields['IsAddressChanged__c'] = true;
                this.servicePointRetrievedData['SupplyStreetNumberExtension__c'] = this.theRecord['Estens.Civico'];
            }
            if (this.servicePointRetrievedData['SupplyStreetNumber__c'] != this.theRecord['Civico']) {
                this.allSubmitedFields['IsAddressChanged__c'] = true;
                this.servicePointRetrievedData['SupplyStreetNumber__c'] = this.theRecord['Civico'];
            }
            if (this.servicePointRetrievedData['SupplyIsAddressVerified__c'] != this.theRecord['Flag Verificato']) {
                this.allSubmitedFields['IsAddressChanged__c'] = true;
                this.servicePointRetrievedData['SupplyIsAddressVerified__c'] = this.theRecord['Flag Verificato'];
            }
            if (this.servicePointRetrievedData['SupplyPlaceCode__c'] != this.theRecord['Codice Localita']) {
                this.allSubmitedFields['IsAddressChanged__c'] = true;
                this.servicePointRetrievedData['SupplyPlaceCode__c'] = this.theRecord['Codice Localita'];
            }
            if (this.servicePointRetrievedData['SupplyPlace__c'] != this.theRecord['Localita']) {
                this.allSubmitedFields['IsAddressChanged__c'] = true;
                this.servicePointRetrievedData['SupplyPlace__c'] = this.theRecord['Localita'];
            }
        }
    }

    updateSubmitedField() {
        if (this.allSubmitedFields != undefined) {

            if (this.allSubmitedFields['SupplyStreet__c'] != this.theRecord['Via']) {
                this.allSubmitedFields['SupplyStreet__c'] = this.theRecord['Via'];
            }
            if (this.allSubmitedFields['SupplyCity__c'] != this.theRecord['Comune']) {
                this.allSubmitedFields['SupplyCity__c'] = this.theRecord['Comune'];
            }
            if (this.allSubmitedFields['SupplyPostalCode__c'] != this.theRecord['CAP']) {
                this.allSubmitedFields['SupplyPostalCode__c'] = this.theRecord['CAP'];
            }
            if (this.allSubmitedFields['SupplyCountry__c'] != this.theRecord['Stato']) {
                this.allSubmitedFields['SupplyCountry__c'] = this.theRecord['Stato'];
            }
            if(!this.allSubmitedFields['SupplyCountry__c']){
                this.allSubmitedFields['SupplyCountry__c'] = 'ITALIA';
            }
            if (this.allSubmitedFields['SupplyProvince__c'] != this.theRecord['Provincia']) {
                this.allSubmitedFields['SupplyProvince__c'] = this.theRecord['Provincia'];
            }
            if (this.allSubmitedFields['SupplySAPCityCode__c'] != this.theRecord['Codice Comune SAP']) {
                this.allSubmitedFields['SupplySAPCityCode__c'] = this.theRecord['Codice Comune SAP'];
            }
            if (this.allSubmitedFields['SupplySAPStreetCode__c'] != this.theRecord['Codice Via Stradario SAP']) {
                this.allSubmitedFields['SupplySAPStreetCode__c'] = this.theRecord['Codice Via Stradario SAP'];
            }
            if (this.allSubmitedFields['SupplyStreetNumberExtension__c'] != this.theRecord['Estens.Civico']) {
                this.allSubmitedFields['SupplyStreetNumberExtension__c'] = this.theRecord['Estens.Civico'];
            }
            if (this.allSubmitedFields['SupplyStreetNumber__c'] != this.theRecord['Civico']) {
                this.allSubmitedFields['SupplyStreetNumber__c'] = this.theRecord['Civico'];
            }
            if (this.allSubmitedFields['SupplyIsAddressVerified__c'] != this.theRecord['Flag Verificato']) {
                this.allSubmitedFields['SupplyIsAddressVerified__c'] = this.theRecord['Flag Verificato'];
            }
            if (this.allSubmitedFields['SupplyPlaceCode__c'] != this.theRecord['Codice Localita']) {
                this.allSubmitedFields['SupplyPlaceCode__c'] = this.theRecord['Codice Localita'];
            }
            if (this.allSubmitedFields['SupplyPlace__c'] != this.theRecord['Localita']) {
                this.allSubmitedFields['SupplyPlace__c'] = this.theRecord['Localita'];
            }
        }
    }

    alert(title, msg, variant) {
        const event = ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: 'sticky' 
        });
        dispatchEvent(event);
    }

    validFieldsUpdateServicePoint() {

        let concatPointErrorFields = '';
        if (this.allSubmitedFields['CommoditySector__c'] == 'Energia Elettrica') {

            if ((this.allSubmitedFields['Distributor__c'] === undefined || this.allSubmitedFields['Distributor__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Distributore, ');
            }
            if ((this.allSubmitedFields['SupplyType__c'] === undefined || this.allSubmitedFields['SupplyType__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Tipo Fornitura, ');
            }
            if ((this.allSubmitedFields['ImplantType__c'] === undefined || this.allSubmitedFields.ImplantType__c === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Tipologia Impianto, ');
            }
            if ((this.allSubmitedFields['MarketOrigin__c'] === undefined || this.allSubmitedFields['MarketOrigin__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Mercato di provenienza, ');
            }
            if ((this.allSubmitedFields['PowerAvailable__c'] === undefined || this.allSubmitedFields['PowerAvailable__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Potenza Disponibile, ');
            }
            if ((this.allSubmitedFields['PowerContractual__c'] === undefined || this.allSubmitedFields['PowerContractual__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Potenza Contrattuale, ');
            }
            if ((this.allSubmitedFields['PlugPresence__c'] === undefined || this.allSubmitedFields['PlugPresence__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Presenza Allaccio, ');
            }
            if ((this.allSubmitedFields['MeterType__c'] === undefined || this.allSubmitedFields['MeterType__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Tipo Apparecchiatura, ');
            }
            if (this.allSubmitedFields['Disconnectable__c'] === 'No' && (this.allSubmitedFields['DisconnectibilityType__c'] === undefined || this.allSubmitedFields['DisconnectibilityType__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Tipologia Disalimentabilita, ');
            }
            //27/08/2021 - gabriele.rota@webresults.it - Tensione di Consegna obbligatoria
            if (this.allSubmitedFields['VoltageLevel__c'] === undefined || this.allSubmitedFields['VoltageLevel__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Tensione di Consegna, ');
            }
            if (this.allSubmitedFields['AnnualConsumption__c'] === undefined || this.allSubmitedFields['AnnualConsumption__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Consumo Annuo, ');
            }
        }
        else if (this.allSubmitedFields['CommoditySector__c'] == 'Acqua') {

            if ((this.allSubmitedFields['SupplyType__c'] === undefined || this.allSubmitedFields['SupplyType__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Tipo Fornitura, ');
            }
            if ((this.allSubmitedFields['ImplantType__c'] === undefined || this.allSubmitedFields.ImplantType__c === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Tipologia Impianto, ');
            }
            if (this.allSubmitedFields['MeterClass__c'] === undefined || this.allSubmitedFields['MeterClass__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Classe Contatore, ');
            }
            if (this.allSubmitedFields['Disconnectable__c'] === 'No' && (this.allSubmitedFields['DisconnectibilityType__c'] === undefined || this.allSubmitedFields['DisconnectibilityType__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Tipologia Disalimentabilita, ');
            }
            if ((this.allSubmitedFields['PlugPresence__c'] === undefined || this.allSubmitedFields['PlugPresence__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Presenza Allaccio, ');
            }
        }
        else if (this.allSubmitedFields['CommoditySector__c'] == 'Gas') {

            if ((this.allSubmitedFields['Distributor__c'] === undefined || this.allSubmitedFields['Distributor__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Distributore, ');
            }
            if ((this.allSubmitedFields['ImplantType__c'] === undefined || this.allSubmitedFields['ImplantType__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Tipologia Impianto, ');
            }
            if ((this.allSubmitedFields['SupplyType__c'] === undefined || this.allSubmitedFields['SupplyType__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Tipo Fornitura, ');
            }
            if ((this.allSubmitedFields['MarketOrigin__c'] === undefined || this.allSubmitedFields['MarketOrigin__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Mercato di provenienza, ');
            }
            if ((this.allSubmitedFields['WithdrawalClass__c'] === undefined || this.allSubmitedFields['WithdrawalClass__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Classe di prelievo, ');
            }
            if ((this.allSubmitedFields['UseCategory__c'] === undefined || this.allSubmitedFields['UseCategory__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Categoria uso, ');
            }
            if (this.allSubmitedFields['Disconnectable__c'] === 'No' && (this.allSubmitedFields['DisconnectibilityType__c'] === undefined || this.allSubmitedFields['DisconnectibilityType__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Tipologia Disalimentabilita, ');
            }
            if (this.allSubmitedFields['AnnualConsumption__c'] === undefined || this.allSubmitedFields['AnnualConsumption__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Consumo Annuo, ');
            }
            if (this.allSubmitedFields['MaxRequiredPotential__c'] === undefined || this.allSubmitedFields['MaxRequiredPotential__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Potenzialità Massima Richiesta, ');
            }
            if (this.allSubmitedFields['MeterClass__c'] === undefined || this.allSubmitedFields['MeterClass__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Classe Contatore, ');
            }
        }
        if (concatPointErrorFields !== '') {
            this.isValid = false;
            this.isValidFields = false;
            this.loading = false;
            this.alert('Dati tabella', 'Per poter salvare popolare i seguenti campi : ' + concatPointErrorFields.slice(0, -2), 'error')
        }
        if (this.allSubmitedFields['CommoditySector__c'] == 'Acqua' &&
            this.isSap === true &&
            this.allSubmitedFields['ImplantType__c'] !== undefined && 
            this.allSubmitedFields['ImplantType__c']  === '1100-ACQUA --- Non definito ---') {
                this.isValid = false;
                this.isValidFields = false;
                this.loading = false;
                this.alert('Dati tabella', 'Selezionare un Tipo Impianto differente.', 'error');
        }
    }

    validFieldsCreateServicePoint() {
        
        let concatPointErrorFields = '';
        if (this.allSubmitedFields['CommoditySector__c'] == 'Energia Elettrica') {

            if (this.allSubmitedFields['ServicePointCode__c'] !== undefined 
            && this.allSubmitedFields['ServicePointCode__c'] !== ''
            && this.allSubmitedFields['ServicePointCode__c'].length < 14) {
                this.isValid = false;
                this.isValidFields = false;
                this.loading = false;
                this.alert('Dati tabella', 'Il POD/PDR non può avere meno di 14 caratteri');
            }

            if (this.allSubmitedFields['PlugPresence__c'] == 'Si' && (this.allSubmitedFields['ServicePointCode__c'] === undefined || this.allSubmitedFields['ServicePointCode__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Codice Punto, ');
            }
            if (this.allSubmitedFields['CommoditySector__c'] === undefined || this.allSubmitedFields['CommoditySector__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Servizio, ');
            }
            if (this.allSubmitedFields['Distributor__c'] === undefined || this.allSubmitedFields['Distributor__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Distributore, ');
            }
            if (this.allSubmitedFields['SupplyType__c'] === undefined || this.allSubmitedFields['SupplyType__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Tipo Fornitura, ');
            }
            if (this.allSubmitedFields['ImplantType__c'] === undefined || this.allSubmitedFields['ImplantType__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Tipologia Impianto, ');
            }
            if (this.allSubmitedFields['MarketOrigin__c'] === undefined || this.allSubmitedFields['MarketOrigin__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Mercato di provenienza, ');
            }
            if (this.allSubmitedFields['PowerAvailable__c'] === undefined || this.allSubmitedFields['PowerAvailable__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Potenza Disponibile, ');
            }
            if (this.allSubmitedFields['PowerContractual__c'] === undefined || this.allSubmitedFields['PowerContractual__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Potenza Contrattuale, ');
            }
            if (this.allSubmitedFields['PlugPresence__c'] === undefined || this.allSubmitedFields['PlugPresence__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Presenza Allaccio, ');
            }
            if (this.allSubmitedFields['MeterType__c'] === undefined || this.allSubmitedFields['MeterType__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Tipo Apparecchiatura, ');
            }
            if (this.allSubmitedFields['Disconnectable__c'] === 'No' && (this.allSubmitedFields['DisconnectibilityType__c'] === undefined || this.allSubmitedFields['DisconnectibilityType__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Tipologia Disalimentabilita, ');
            }
            //27/08/2021 - gabriele.rota@webresults.it - Tensione di Consegna obbligatoria
            if (this.allSubmitedFields['VoltageLevel__c'] === undefined || this.allSubmitedFields['VoltageLevel__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Tensione di Consegna, ');
            }
            if (this.allSubmitedFields['AnnualConsumption__c'] === undefined || this.allSubmitedFields['AnnualConsumption__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Consumo Annuo, ');
            }
        }
        else if (this.allSubmitedFields['CommoditySector__c'] == 'Acqua') {            
            if (this.allSubmitedFields['PlugPresence__c'] === undefined || this.allSubmitedFields['PlugPresence__c'] === '') {
                this.allSubmitedFields['PlugPresence__c'] = 'No';
            }
            if (this.allSubmitedFields['SupplyType__c'] === undefined || this.allSubmitedFields['SupplyType__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Tipo Fornitura, ');
            }
            if (this.allSubmitedFields['ImplantType__c'] === undefined || this.allSubmitedFields['ImplantType__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Tipologia Impianto, ');
            }
            if (this.allSubmitedFields['MeterClass__c'] === undefined || this.allSubmitedFields['MeterClass__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Classe Contatore, ');
            }
            if (this.allSubmitedFields['Disconnectable__c'] === 'No' && (this.allSubmitedFields['DisconnectibilityType__c'] === undefined || this.allSubmitedFields['DisconnectibilityType__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Tipologia Disalimentabilita, ');
            }
        }
        else if (this.allSubmitedFields['CommoditySector__c'] == 'Gas') {

            if (this.allSubmitedFields['ServicePointCode__c'] !== undefined 
            && this.allSubmitedFields['ServicePointCode__c'] !== ''
            && this.allSubmitedFields['ServicePointCode__c'].length < 14) {
                this.isValid = false;
                this.isValidFields = false;
                this.loading = false;
                this.alert('Dati tabella', 'Il POD/PDR non può avere meno di 14 caratteri');
            }
            if (this.allSubmitedFields['ServicePointCode__c'] === undefined || this.allSubmitedFields['ServicePointCode__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Codice Punto, ');
            }
            if ((this.allSubmitedFields['ImplantType__c'] === undefined || this.allSubmitedFields['ImplantType__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Tipologia Impianto, ');
            }
            if (this.allSubmitedFields['CommoditySector__c'] === undefined || this.allSubmitedFields['CommoditySector__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Servizio, ');
            }
            if (this.allSubmitedFields['Distributor__c'] === undefined || this.allSubmitedFields['Distributor__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Distributore, ');
            }
            if (this.allSubmitedFields['SupplyType__c'] === undefined || this.allSubmitedFields['SupplyType__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Tipo Fornitura, ');
            }
            if (this.allSubmitedFields['MarketOrigin__c'] === undefined || this.allSubmitedFields['MarketOrigin__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Mercato di provenienza, ');
            }
            if (this.allSubmitedFields['WithdrawalClass__c'] === undefined || this.allSubmitedFields['WithdrawalClass__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Classe di prelievo, ');
            }
            if (this.allSubmitedFields['UseCategory__c'] === undefined || this.allSubmitedFields['UseCategory__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Categoria uso, ');
            }
            if (this.allSubmitedFields['Disconnectable__c'] === 'No' && (this.allSubmitedFields['DisconnectibilityType__c'] === undefined || this.allSubmitedFields['DisconnectibilityType__c'] === '')) {
                concatPointErrorFields = concatPointErrorFields.concat('Tipologia Disalimentabilita, ');
            }
            if (this.allSubmitedFields['AnnualConsumption__c'] === undefined || this.allSubmitedFields['AnnualConsumption__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Consumo Annuo, ');
            }
            if (this.allSubmitedFields['MaxRequiredPotential__c'] === undefined || this.allSubmitedFields['MaxRequiredPotential__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Potenzialità Massima Richiesta, ');
            }
            if (this.allSubmitedFields['MeterClass__c'] === undefined || this.allSubmitedFields['MeterClass__c'] === '') {
                concatPointErrorFields = concatPointErrorFields.concat('Classe Contatore, ');
            }
        }
        if (concatPointErrorFields !== '') {
            this.isValid = false;
            this.isValidFields = false;
            this.loading = false;
            this.alert('Dati tabella', 'Per poter salvare popolare i seguenti campi : ' + concatPointErrorFields.slice(0, -2), 'error')
        }
        if (this.allSubmitedFields['CommoditySector__c'] == 'Acqua' &&
            this.isSap === true &&
            this.allSubmitedFields['ImplantType__c'] !== undefined && 
            this.allSubmitedFields['ImplantType__c']  === '1100-ACQUA --- Non definito ---') {
                this.isValid = false;
                this.isValidFields = false;
                this.loading = false;
                this.alert('Dati tabella', 'Selezionare un Tipo Impianto differente.', 'error');
        }
    }

    validFields() {
        return new Promise((resolve, reject) => {
            this.loading = true;
            this.isValidFields = true;
            let concatAddressErrorFields = '';

            //@DV: Controllo sull'obbligatorietà dei campi. Se non valorizzati, lancio l'errore!
            if (this.recordtype.label === 'Punto Elettrico' || this.recordtype.label == 'Punto Gas' || this.recordtype.label == 'Punto Idrico' || this.recordtype.label == 'Punto Ambiente') {
                this.validFieldsCreateServicePoint();
            }
            else {
                this.validFieldsUpdateServicePoint();
            }

            //Validate address
            if (this.theRecord['Indirizzo Estero'] == false || this.theRecord['Indirizzo Estero'] == undefined) {
                if (this.theRecord['Flag Verificato'] == false || this.theRecord['Flag Verificato'] == undefined) {
                    this.isValidFields = false;
                    this.loading = false;
                    this.alert('Dati tabella', 'E\' necessario verificare l\'indirizzo per poter procedere al salvataggio', 'error');
                }
            }
            else {

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
                    this.isValidFields = false;
                    this.loading = false;
                    this.alert('Dati tabella', 'Per poter salvare popolare i seguenti campi di indirizzo: ' + concatAddressErrorFields.slice(0, -2), 'error')
                }
            }

            console.log('### Error Skip Dimensione' + JSON.stringify(this.selectedDistributor));
/*             if (this.selectedDistributor!== undefined && !this.selectedDistributor['SkipDimensione__c'] && (this.allSubmitedFields['ServicePointCode__c'] != undefined) && (this.allSubmitedFields['ServicePointCode__c'] != '')) {
                //Ele e Gas, SPCode.length = 14
                if((this.allSubmitedFields['ServicePointCode__c'] == 'Energia Elettrica' || this.allSubmitedFields['ServicePointCode__c'] == 'Gas') && this.allSubmitedFields['ServicePointCode__c'].replace(/\s/g, '').length != 14){
                    this.isValidFields = false;
                    this.loading = false;
                    this.alert('Errore', 'Codice POD/PDR non valido', 'error');
                //Inutilizzato
                }else if(this.allSubmitedFields['ServicePointCode__c'] == 'Acqua' && (this.allSubmitedFields['ServicePointCode__c'].replace(/\s/g, '').length < 5 || this.allSubmitedFields['ServicePointCode__c'].replace(/\s/g, '').length > 20)){
                    this.isValidFields = false;
                    this.loading = false;
                    this.alert('Errore', 'Codice POD/PDR non valido', 'error');
                }
            } */

            if (this.allSubmitedFields['ServicePointCode__c'] !== undefined && this.allSubmitedFields['ServicePointCode__c'] !== '')
            {
                this.allSubmitedFields['ServicePointCode__c'] = this.allSubmitedFields['ServicePointCode__c'].replace(/\s/g, '');
                
                if( this.allSubmitedFields['CommoditySector__c'] === 'Energia Elettrica' && 
                    ( 
                        ( this.allSubmitedFields['PlugPresence__c'] === 'Si' && this.allSubmitedFields['ServicePointCode__c'].substring(0, 2) != 'IT' ) || 
                        this.allSubmitedFields['ServicePointCode__c'].length !== 14 
                    ) 
                  )
                {
                    this.isValidFields = false;
                    this.loading = false;
                    this.alert('Errore', 'Codice POD non valido', 'error');
                }
                else if( this.allSubmitedFields['CommoditySector__c'] === 'Gas' && 
                        ( this.allSubmitedFields['ServicePointCode__c'].length !== 14 || !this.isNumeric(this.allSubmitedFields['ServicePointCode__c']) ) )
                {
                    this.isValidFields = false;
                    this.loading = false;
                    this.alert('Errore', 'Codice POD non valido', 'error');
                }
                else if( this.allSubmitedFields['CommoditySector__c'] == 'Acqua' &&
                        ( this.allSubmitedFields['ServicePointCode__c'].length < 5 || this.allSubmitedFields['ServicePointCode__c'].length > 20) )
                {
                    this.isValidFields = false;
                    this.loading = false;
                    this.alert('Errore', 'Codice Punto non valido', 'error');
                }
                
            }

            //Check di coerenza campi SP Gas
            let checkFieldMap = {};
            if(this.recordtype.label == 'Punto Gas' || this.servicePointRetrievedData['CommoditySector__c'] == 'Gas'){
                let imposta = this.servicePointRetrievedData['ExciseGas__c'] != undefined ? this.servicePointRetrievedData['ExciseGas__c'] : '';
                checkFieldMap['CategoriaCliente'] = this.accRecord.fields.Category__c.value;
                checkFieldMap['TipoFornitura'] = this.allSubmitedFields['SupplyType__c'];
                checkFieldMap['TipoImpianto'] = this.allSubmitedFields['ImplantType__c'];
                checkFieldMap['Servizio'] = this.allSubmitedFields['CommoditySector__c'];
                checkFieldMap['ProfiloPrelievo'] = this.allSubmitedFields['WithdrawalClass__c'];
                checkFieldMap['CategoriaUso'] = this.allSubmitedFields['UseCategory__c'];
                checkFieldMap['Imposta'] = imposta;
                checkFieldMap['searchTaxes'] = false;

                /*checkFieldCoerenceSpGas({
                    inputFieldMap : checkFieldMap
                })
                .then(hasCoerence => {
                    if(!hasCoerence){
                        let errMess = 'Attenzione. Deve esserci coerenza nella compilazione dei seguenti campi: Tipologia Fornitura Cliente, Categoria Cliente, Tipo Impianto';
                        errMess += (this.accRecord.fields.Category__c.value == 'Famiglie' || this.accRecord.fields.Category__c.value == 'Grandi Condomini' || this.accRecord.fields.Category__c.value == 'Piccoli Condomini') ? ', Classe Profilo Prelievo, Categoria uso' : '';
                        //errMess += (imposta != '') ? ', Imposta' : '';
                        errMess += '.';
                        this.isValidFields = false;
                        this.loading = false;
                        this.alert('Errore', errMess, 'error');
                        resolve();
                    }
                    resolve();
                })
                .catch(error => {
                    this.isValidFields = false;
                    this.loading = false;
                    this.alert('Errore', 'Errore nel processo di controllo coerenza campi!', 'error');
                    resolve();
                });*/
            }
            
            //Check di coerenza campi SP Energia Elettrica
            /*if(this.recordtype.label == 'Punto Elettrico' || this.servicePointRetrievedData['CommoditySector__c'] == 'Energia Elettrica'){
                if(this.allSubmitedFields['PowerRequested__c'] > 10 && this.allSubmitedFields['RequestPhase__c'] != 'Trifase'){
                    this.isValidFields = false;
                    this.loading = false;
                    this.alert('Errore', 'Se la Potenza Richiesta è maggiore di 10, la Fase Richiesta deve essere Trifase', 'error');
                }
                if(this.allSubmitedFields['SupplyType__c'] == 'Domestico' && this.allSubmitedFields['ImplantType__c'] != '13A0-Usi di Abitazione BT'){
                    this.isValidFields = false;
                    this.loading = false;
                    this.alert('Errore', 'Se il Tipo Fornitura è Domestico, la Tipologia Impianto deve essere 13A0-Usi di Abitazione BT', 'error');
                }
                if(this.allSubmitedFields['SupplyType__c'] != 'Domestico' && this.allSubmitedFields['ImplantType__c'] == '13A0-Usi di Abitazione BT'){
                    this.isValidFields = false;
                    this.loading = false;
                    this.alert('Errore', 'Se il Tipo Fornitura è Non Domestico, la Tipologia Impianto non può essere 13A0-Usi di Abitazione BT!', 'error');
                }
                resolve();
            }*/

            if ( this.sale ) {
                checkFieldMap['CompanyOwner__c'] = this.sale['Account__r']['CompanyOwner__c'];
            }
            if ( !checkFieldMap['SupplyCity__c'] ) 
            {
                checkFieldMap['SupplyCity__c'] = this.theRecord['Comune'];
            }
            
            /**Check coerenza tipo fornitura - mercato di provenienza */
            checkCoerenceServicePoint({servicePoint: this.allSubmitedFields, inputFieldMap: checkFieldMap})
            .then(result =>
                {
                    let dataObj = JSON.parse(result);
                    console.log('### Check Coerence Service Point Object Result >>>' + result);
                    if(dataObj.valid === true)
                    {
                        console.log('### CheckCoerenceServicePoint inside Resolve ###');
                        resolve();
                    }
                    else
                    {
                        console.log('### CheckCoerenceServicePoint inside Reject ###');
                        this.isValidFields = false;
                        reject(dataObj.message);
                    }
                }
            )
            .catch(error =>
                {
                    this.isValidFields = false;
                    console.log('#Error >>> ' + JSON.stringify(error));
                    reject(error.body.message);
                }
            );
        });
    }

    handleNotifyModificaContr(cases){
        if(!cases.length) return;
        let variant = cases[0]?.Phase__c === "Sospesa" ? "error" : "warning";
        let cNums = cases.reduce((caseNumbers, elem ,index, array)=>{
            return index==0? elem.CaseNumber : `${caseNumbers}, ${elem.CaseNumber}`;
        }, 0);

        const event = new ShowToastEvent({
            "title": "Attenzione!",
            "message": `Questo Pod/Pdr risulta nei seguenti Ticket di modifica contratti in Preattivazione ${cNums}!`,
            "variant": variant,
            "mode": "sticky"       
         });
        this.dispatchEvent(event);
    }

    async populateDistributor(){

        //W2 blocco per classe contatore non gestita
        if(this.allSubmitedFields['CommoditySector__c'] === 'Acqua' &&  !this.allSubmitedFields['MeterSN__c'] && !this.managedMeterClass.includes(this.allSubmitedFields['MeterClass__c'])){
            this.alert('Errore', 'La classe contatore selezionata non può essere utilizzata per il servizio Acqua.', 'error');
        }else{

            this.loading = true;
            let addressRecord = this.template.querySelector('c-hdt-target-object-address-fields').handleAddressFields();
            console.log('XXX populateDistributor I');
            // Calcolo ATO per Idrico
            if(this.allSubmitedFields['CommoditySector__c'] === 'Acqua' ){
                let ato = await getATO({comune : addressRecord['Comune']});
                this.allSubmitedFields['ATO__c'] = ato;
            }
    
            if(this.spCodeChanged || this.allSubmitedFields['Distributor__c'] == undefined || this.allSubmitedFields['Distributor__c'].trim() == ''){
                console.log('XXX populateDistributor III');
                if((this.allSubmitedFields['CommoditySector__c'] == 'Energia Elettrica' && this.allSubmitedFields['PlugPresence__c'] == 'Si' && this.allSubmitedFields['ServicePointCode__c'] != undefined && this.allSubmitedFields['ServicePointCode__c'].replace(/\s/g, '') != '') ||
                (this.allSubmitedFields['CommoditySector__c'] == 'Energia Elettrica' && this.allSubmitedFields['PlugPresence__c'] == 'No') ||
                (this.allSubmitedFields['CommoditySector__c'] == 'Gas' && this.allSubmitedFields['ServicePointCode__c'] != undefined && this.allSubmitedFields['ServicePointCode__c'].replace(/\s/g, '') != '') ||
                (this.allSubmitedFields['CommoditySector__c'] == 'Acqua') ||
                (this.allSubmitedFields['CommoditySector__c'] == 'Ambiente')){
                    console.log('XXX populateDistributor IIII');                    
                    if(addressRecord['Comune'] != undefined && addressRecord['Comune'].trim() != ''){
                        console.log('XXX populateDistributor IIIII'); 
                        let codicePunto = '';
                        let servizio = this.allSubmitedFields['CommoditySector__c'];
                        let radicePunto = '';
                        if(this.allSubmitedFields['ServicePointCode__c'] != undefined && this.allSubmitedFields['ServicePointCode__c'].replace(/\s/g, '') != ''){
                            codicePunto = this.allSubmitedFields['ServicePointCode__c'].replace(/\s/g, '');
                            radicePunto = servizio == 'Gas' ? codicePunto.substring(0, 4) : codicePunto.substring(0, 6);
                        }
                        if(this.allSubmitedFields['PlugPresence__c'] == 'No' && this.allSubmitedFields['CommoditySector__c'] != 'Acqua'){
                            this.allSubmitedFields['ServicePointCode__c'] = 'PODPROVVISORIO';//POD FITTIZIO
                        }
                        let comune = servizio == 'Gas' || servizio == 'Acqua' || servizio == 'Ambiente' ? addressRecord['Comune'] : '';
                        let presenzaAllaccio = this.allSubmitedFields['PlugPresence__c'] != undefined ? this.allSubmitedFields['PlugPresence__c'] : '';
                        console.log('XXX Calcolo distributor: '+radicePunto+'|'+servizio+'|'+comune+'|'+presenzaAllaccio);
                        getDistributorPointCode({code : radicePunto, commodity: servizio, comune : comune, presenzaAllaccio: presenzaAllaccio}).then(data => {
    
                            this.retrievedDistributor = data;
                            if (data.length > 1) {
                                this.booleanFormDistributor = true;
                                this.loading = false;
                            }
                            else {
                                data.forEach(element => {
                                    this.recordDistributorPointCode = element.Account__r.Id;
                                    this.selectedDistributor = element;
                                });
                                this.isDistributor = true;
                                this.allSubmitedFields['Distributor__c'] = this.recordDistributorPointCode;
    
                                let distributorObject = {...this.servicePointRetrievedData};
                                distributorObject['Distributor__c'] = this.recordDistributorPointCode;
                                this.servicePointRetrievedData = {...distributorObject};
    
                                this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);
                                this.save();
                            }
                        }).catch(error => 
                            {
                                this.loading = false;
                                this.alert('Errore', 'Distributore non calcolato. Verificare di aver inserito i dati correttamente e in caso contattare l\'amministratore di sistema', 'error');
                            }
                        );
                    }
                    else {
                        this.loading = false;
                        this.alert('Errore', 'E\' necessario inserire il Comune per poter procedere al salvataggio', 'error');
                    }
                }
                else {
                    this.loading = false;
                    this.alert('Errore', 'E\' necessario inserire il Codice Punto per poter procedere al salvataggio', 'error');
                }
            }
            else{
                this.save();
            }
        }
    }

    /**
     * Handle new record creation
     */
    async save() {

        this.loading = true;
        let isBlacklist = await isInBlacklist({ pod: this.allSubmitedFields['ServicePointCode__c'] });
        let orderModificaContratti = await searchModificaContratti({podPdr: this.allSubmitedFields['ServicePointCode__c']});
        let noSuspendedCases = orderModificaContratti?.length === 0 || orderModificaContratti[0]?.Phase__c==="Chiuso";
        this.handleNotifyModificaContr(orderModificaContratti);

        if (!isBlacklist && noSuspendedCases) {
            this.theRecord = this.template.querySelector('c-hdt-target-object-address-fields').handleAddressFields();
            if (this.theRecord['Stato'] == 'Italy' || this.theRecord['Stato'] == 'Italia') {
                this.theRecord['Stato'] == 'ITALIA';
            }
            this.validFields().then(() => {
                if (this.isValidFields == true) {
                    this.validationChecks();
                    console.log('XXX Save: validForm -> '+this.validForm);
                    if (this.validForm) {
                        this.loading = true;
                        this.checkForTari();
                        if (this.selectedservicepoint != undefined) {
                            console.log('XXX Save: UpdateServicePoint ');
                            this.updateServicePoint();
                            this.confirm();
                        }
                        else {
                            console.log('XXX Save: CreateServicePoint ');
                            this.updateSubmitedField();
                            this.create();
                        }
                    }
                    else {
                        this.template.querySelector('c-hdt-target-object-address-fields').checkInvalidFields(this.fieldsAddressWithError);
                        for (var i = 0; i < this.fieldsDataWithError.length; i++) {
                            let dataName = "[data-name='" + this.fieldsDataWithError[i] + "']";
                            let dataField = this.template.querySelector(dataName);
                            dataField.reportValidity();
                        }
                    }
                }
            })
            .catch(error => 
                {
                    console.log(error);
                    this.alert('Errore!', error, 'error');
                    this.loading = false;
                }
            );
        }
        else if(isBlacklist){
            this.loading = false;
            this.alert('Errore', 'Non è possibile procedere in quanto il POD/PD ricercato è presente in Black List', 'error');
        }
    }

    /**
     * Get form title
     */
    get formTitle() {
        let title = 'Service Point: ';

        if (this.selectedservicepoint !== undefined) {
            if (this.selectedservicepoint['Codice Punto'] !== undefined) {
                title += this.selectedservicepoint['Codice Punto'];
            }
            else if (this.selectedservicepoint['Codice Punto'] === undefined) {

                let sp = JSON.stringify(this.selectedservicepoint).split(',');
                sp.forEach(element => {
                    if (element.split(':')[0].includes('ServicePointCode__c')) {
                        title += element.split(':')[1];
                    }
                    if (element.split(':')[0].includes('Codice Punto')) {
                        title += element.split(':')[1];
                    }

                });
                this.isSap = true;
            }
        }
        else {
            title += this.recordtype.label;
        }
        return title;
    }

    checkForTari() {
        canHandleTari({ comune: this.theRecord['Comune'], commodity: this.commodity }).then(data => {
            
            if(data){
                const toastSuccessMessage = new ShowToastEvent({
                    title: '',
                    message: 'Per questo comune è disponibile il servizio TARI',
                    variant: 'Alert'
                });
                this.dispatchEvent(toastSuccessMessage);
            }

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
     * Get verify address for update case
     * @param {*} event 
     */
    handleVerifyAddressOnUpdate(event) {
        this.verifyAddressDisabledOnUpdate = event.detail;
    }

    /**
     * Create record
     */
    create() {

        createServicePoinString({ servicePoint: JSON.stringify(this.allSubmitedFields), sale: this.sale, callWinBack: this.callWinBack }).then(data => {

            this.loading = false;
            this.closeCreateTargetObjectModal();
            this.servicePointId = data.id;
            this.newServicePoint = data;

            this.dispatchEvent(new CustomEvent('newservicepoint', { detail: this.newServicePoint }));
            this.dispatchEvent(new CustomEvent('confirmservicepoint', { detail: this.newServicePoint }));

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
    confirm() {
        if(this.existsServicePoint)
        {
            this.isSap = false;
        }
        if (this.allSubmitedFields['Id'] != undefined && this.isSap == true) {
            delete this.allSubmitedFields['Id'];
        }
        console.log('##171020222_TargetObjectCreateForm## isSap >>> ' + this.isSap);
        confirmServicePoint({ servicePoint: this.allSubmitedFields, sap: this.isSap, sale: this.sale }).then(data => {
            this.loading = false;
            this.closeCreateTargetObjectModal();
            this.servicePointId = data.id;
            this.newServicePoint = data;
            this.isSap = false;
            this.dispatchEvent(new CustomEvent('newservicepoint', { detail: this.newServicePoint }));
            this.dispatchEvent(new CustomEvent('confirmservicepoint', { detail: { newServicePoint: this.newServicePoint, oldSupplyType: this.oldSupplyType } }));
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

    handleResponseHeroku(event) {
        this.herokuAddressResponse = event.detail;
    }

    @api
    closedFormDistributor(event) {
        this.booleanFormDistributor = event.target.value;
    }

    @api
    getDistributorSelected(event) {

        this.retrievedDistributor.forEach(element => {
            if(element.Account__c === undefined || element.Account__r.Name === undefined) return;
            if (event.detail.Distributor === element.Account__r.Name) {
                this.recordDistributorPointCode = element.Account__r.Id;
                this.selectedDistributor = element;
            }
        });
        this.isDistributor = true;
        this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);
        this.save();
    }

    @api
    isNumeric(n) {
        return !isNaN(parseFloat(n)) && isFinite(n);
    }

}