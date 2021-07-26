import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import init from '@salesforce/apex/HDT_LC_ChildOrderProcessPrecheck.init';
import next from '@salesforce/apex/HDT_LC_ChildOrderProcessPrecheck.next';
import checkCompatibility from '@salesforce/apex/HDT_UTL_MatrixCompatibility.checkCompatibilitySales';


// @Picchiri 07/06/21 Credit Check Innesco per chiamata al ws
import callServiceCreditCheck from '@salesforce/apex/HDT_WS_CreditCheck.callService';
export default class hdtChildOrderProcessPrecheck extends LightningElement {
    @api order;
    precheck = false;
    causale = '';
    causaleCompatibilita = '';
    selectedProcess = ''; //old processSelector (deprecated)
    selectedProcessObject = ''; //new processSelector
    compatibilita = false;
    loaded = true;
    deliberation = '';
    showDeliberation = false;
    disabledDeliberation = false;
    showEsitoCheck = false;
    vasAmendDisabledInput = false;
    disabledSelectProcess = false;
    options;
    @track processesReference = [];
    value;
    serviceRequest;

    get disabledNext(){
        let result = true;
        if(this.order.RecordType.DeveloperName !== 'HDT_RT_Default' || (this.selectedProcessObject === '') || this.compatibilita === false){
            result = true;
        } else {
            result = false;
        }
        console.log('disabledSave: ', result);
        return result;
    }

    get disabledInput(){
        let result = true;
        console.log('disabledInput - rcordtype', this.order.RecordType.DeveloperName);
        if(this.order.RecordType.DeveloperName !== 'HDT_RT_Default' || this.disabledSelectProcess){
            result = true;
        } else {
            result = false;
        }
        console.log('disabledInput: ', result);
        return result;
    }

    handleDeliberateSelection(event){
        this.deliberation = event.currentTarget.value;
    }

    applySelectionLogic(selectedProcess){
        console.log('applySelectionLogic: ', JSON.stringify(selectedProcess));

        if(selectedProcess.recordType === 'HDT_RT_Attivazione')
        {
            // this.precheck = false;
            // this.compatibilita = true;
            // this.causale = 'E necessario effettuare un subentro';

            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';

            this.showDeliberation = this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas';
            this.disabledDeliberation = this.order.Step__c !== undefined;
        }
        else if(selectedProcess.recordType === 'HDT_RT_RiattivazioniNonMorose'){
            this.showDeliberation = this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas';
            this.disabledDeliberation = this.order.Step__c !== undefined;
        }
        else if(selectedProcess.recordType === 'HDT_RT_Subentro')
        {
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        else if(selectedProcess.recordType === 'HDT_RT_SwitchIn')
        {
            // this.precheck = false;
            this.precheck = true;
            // this.compatibilita = false;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;

            this.showEsitoCheck = false;

        }
        else if(selectedProcess.recordType === 'HDT_RT_AttivazioneConModifica')
        {
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        else if(selectedProcess.recordType === 'HDT_RT_VAS')
        {
            this.selectedProcessObject.recordType = 'HDT_RT_VAS';
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        else if(selectedProcess.recordType === 'HDT_RT_CambioOfferta')
        {
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        else if(selectedProcess.recordType === 'HDT_RT_ScontiBonus')
        {
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        //INIZIO SVILUPPI EVERIS
        else if(selectedProcess.recordType === 'HDT_RT_Voltura'){
            this.selectedProcessObject.recordType = 'HDT_RT_Voltura';
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        //FINE SVILUPPI EVERIS 

    }

    incompatibilityfound(selectedProcess, compatibility){
        console.log('incompatibilityfound: ', JSON.stringify(selectedProcess));

        if(selectedProcess.recordType === 'HDT_RT_Attivazione')
        {
            // this.precheck = false;
            // this.compatibilita = true;
            // this.causale = 'E necessario effettuare un subentro';

            this.precheck = true;
            this.compatibilita = false;
            this.causaleCompatibilita = compatibility;

            this.showDeliberation = this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas';
            this.disabledDeliberation = this.order.Step__c !== undefined;
        }
        else if(selectedProcess.recordType === 'HDT_RT_RiattivazioniNonMorose'){
            this.showDeliberation = this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas';
            this.disabledDeliberation = this.order.Step__c !== undefined;
        }
        else if(selectedProcess.recordType === 'HDT_RT_Subentro')
        {
            this.precheck = true;
            this.compatibilita = false;
            this.causaleCompatibilita = compatibility;
            this.showDeliberation = false;
        }
        else if(selectedProcess.recordType === 'HDT_RT_SwitchIn')
        {
            // this.precheck = false;
            this.precheck = true;
            // this.compatibilita = false;
            this.compatibilita = false;
            this.causaleCompatibilita = compatibility;
            this.showDeliberation = false;

            this.showEsitoCheck = false;

        }
        else if(selectedProcess.recordType === 'HDT_RT_AttivazioneConModifica')
        {
            this.precheck = true;
            this.compatibilita = false;
            this.causaleCompatibilita = compatibility;
            this.showDeliberation = false;
        }
        else if(selectedProcess.recordType === 'HDT_RT_VAS')
        {
            this.selectedProcessObject.recordType = 'HDT_RT_VAS';
            this.precheck = true;
            this.compatibilita = false;
            this.causaleCompatibilita = compatibility;
            this.showDeliberation = false;
        }
        else if(selectedProcess.recordType === 'HDT_RT_CambioOfferta')
        {
            this.precheck = true;
            this.compatibilita = false;
            this.causaleCompatibilita = compatibility;
            this.showDeliberation = false;
        }
        else if(selectedProcess.recordType === 'HDT_RT_ScontiBonus')
        {
            this.precheck = true;
            this.compatibilita = false;
            this.causaleCompatibilita = compatibility;
            this.showDeliberation = false;
        }
        //INIZIO SVILUPPI EVERIS
        else if(selectedProcess.recordType === 'HDT_RT_Voltura'){
            this.selectedProcessObject.recordType = 'HDT_RT_Voltura';
            this.precheck = true;
            this.compatibilita = false;
            this.causaleCompatibilita = compatibility;
            this.showDeliberation = false;
        }
        //FINE SVILUPPI EVERIS 

    }

    handleSelectProcess(event){
        console.log('handleSelectProcess: ' + JSON.stringify(event.detail));

        this.selectedProcessObject = this.processesReference.filter(el => el.processType === event.target.value)[0];
        this.checkCompatibilityProcess();
    }

    goToNextStep(extraParams){
        this.loaded = false;

        if(Object.keys(extraParams).length === 0) {
            extraParams = {};
        }

        //EVERIS
        console.log('OrderId--> '+this.order.Id);
        //EVERIS

        //EVERIS: Aggiunta variabile Order
        next({order: this.order,orderId: this.order.Id, selectedProcessObject: this.selectedProcessObject, deliberate: this.deliberation, extraParams: extraParams, srRequest: this.serviceRequest}).then(data =>{
            this.loaded = true;
            this.dispatchEvent(new CustomEvent('refreshorderchild'));

        }).catch(error => {
            this.loaded = true;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleNext(){
        //@Picchiri 07/06/21 Credit Check Innesco per chiamata al ws
        /**
         * La chiamata al credit check va eseguita per queste condizioni
         * HDT_RT_Subentro , HDT_RT_AttivazioneConModifica, HDT_RT_SwitchIn (solo se process_type diverso da Switch In Ripristinatorio), 
         * HDT_RT_ConnessioneConAttivazione, HDT_RT_TemporaneaNuovaAtt, HDT_RT_Voltura, 
         * HDT_RT_VAS (Solo Se: OrderReference__c <> null & ContractReference <> null)
         */
        if((this.selectedProcessObject.recordType === 'HDT_RT_VAS' && (this.order.OrderReferenceNumber == null || this.order.OrderReferenceNumber === undefined) && (this.order.ContractReference__c == null || this.order.ContractReference__c === undefined)) || this.selectedProcessObject.recordType === 'HDT_RT_Voltura' ||this.selectedProcessObject.recordType === 'HDT_RT_Subentro' || this.selectedProcessObject.recordType === 'HDT_RT_AttivazioneConModifica' || (this.selectedProcessObject.recordType === 'HDT_RT_SwitchIn' && this.order.ProcessType__c != 'Switch in Ripristinatorio') || this.selectedProcessObject.recordType === 'HDT_RT_ConnessioneConAttivazione' || this.selectedProcessObject.recordType === 'HDT_RT_TemporaneaNuovaAtt'){
            this.callCreditCheckSAP();
        }
        

        let extraParams = {};

        if(this.order.ServicePoint__r !== undefined){
            extraParams['servicePointType'] = this.order.ServicePoint__r.RecordType.DeveloperName;
        }

        if(this.order.ProcessType__c === 'Switch in Ripristinatorio'){
            extraParams['switchInRipristinatorio'] = 'true';
        }

        if (this.showDeliberation === true) {
            if (this.deliberation !== '') {
                this.goToNextStep(extraParams);
            } else {
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: 'Devi compilare il campo delibera.',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            }
        } else {
            this.goToNextStep(extraParams);
        }

    }

    connectedCallback(){
        console.log('this.order: ', JSON.parse(JSON.stringify(this.order)));

        console.log('CallBack start');

        if (this.order.RecordType.DeveloperName === 'HDT_RT_Default') {
            console.log('enter default');
            init({order: this.order}).then(data =>{
                this.loaded = true;
                console.log('initProcesses: ' + JSON.stringify(data));
    
                this.processesReference = data;

                this.options = [];

                data.forEach(el => {
                    this.options.push({label: el.processType, value: el.processType});
                });
    
    
                if (this.options.length === 1) {
                    this.selectedProcessObject = this.processesReference[0];
                    this.value = this.selectedProcessObject.processType;
                    this.disabledSelectProcess = true;
                    this.checkCompatibilityProcess();
                }
    
                if (this.options.length === 0) {
                    if(this.order.SBQQ__Quote__r.IsVAS__c){
                        this.options.push({label: 'VAS', value: 'VAS'});
                        this.selectedProcessObject = {processType: 'VAS', recordType: 'HDT_RT_VAS'}
                        this.value = this.selectedProcessObject.processType;
                        this.disabledSelectProcess = true;
                        this.checkCompatibilityProcess();
                    }
                }
    
            }).catch(error => {
                this.loaded = true;
                console.log(error.body.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            });

        } else {
            console.log('enter with value');
            this.options = [];
            this.options.push({label: this.order.ProcessType__c, value: this.order.ProcessType__c});
            this.selectedProcessObject = {processType: this.order.ProcessType__c, recordType: this.order.RecordType.DeveloperName}
            this.value = this.selectedProcessObject.processType;
            this.checkCompatibilityProcess();
        }

        console.log('CallBack end');
    }

    // START @Picchiri 07/06/21 Credit Check
    callCreditCheckSAP(){
        this.loading = true;
        var wrp = this.getRequest();
        
        console.log('connectedCallback wrp ---> ');
        console.log(JSON.parse(JSON.stringify(wrp)));
                
        callServiceCreditCheck({wrpVals:JSON.stringify(wrp)})
        .then(result => {
            console.log('result callServiceCreditCheck ---> : ');
            console.log(JSON.parse(JSON.stringify(result)));

            if(result.status == 'failed'){
                throw {body:{message:result.errorDetails[0].code + ' ' + result.errorDetails[0].message}}
            }

            //this.restryEsitiCreditCheck();
            this.loading = false;
        })
        .catch(error => {
            console.log('error callServiceCreditCheck error ---> : ');
            console.log(JSON.parse(JSON.stringify(error)));
            let toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: (error.body.message !== undefined) ? error.body.message : error.message,
                variant: 'error', 
                mode:'sticky'
            });
            
            this.dispatchEvent(toastErrorMessage);
            this.loading = false;
        })        
    }

    getRequest(){ 
        var typeOfCommodity = 'ENERGIAELETTRICA';
        var companyName = null;
        var secondaryCustomerId = null;
        var bpType = null;
        var operation = null;
        var market = null; 
        var offerType = null; 
        console.log("RecordType: " + this.order.RecordType.DeveloperName);
        console.log("typeOfCommodity: " + typeOfCommodity);
        var fiscalData = null;

        if(this.selectedProcessObject.recordType !== 'HDT_RT_VAS'){
            if(this.order.ServicePoint__r.CommoditySector__c == 'Gas'){
                typeOfCommodity = 'GAS';
            }
        }
        if(this.order.SalesCompany__c !== undefined){
            companyName = this.order.SalesCompany__c;
        }
        if(this.order.Account.VATNumber__c !== undefined){
            secondaryCustomerId = this.order.Account.VATNumber__c;
        }
        if(this.order.Account.CustomerType__c !== undefined){
            bpType = this.order.Account.CustomerType__c;
        }
        if(this.order.ProcessType__c !== undefined){
            operation = this.order.ProcessType__c;
        }
        if(this.order.Market__c !== undefined){
            market = this.order.Market__c;
        }
        if(this.order.Catalog__c !== undefined){
            offerType = this.order.Catalog__c;
        }
        console.log("typeOfCommodity: " + typeOfCommodity);
        console.log("this.selectedProcessObject: " + JSON.stringify(this.selectedProcessObject));
        
        let data = {
            sistema: "eEnergy", //in attesa verifica M.Tatti valorizzazione dinamica
            caso:"Transazionale",
            crmEntity:"Order",
            crmId:this.order.OrderNumber,
            userId: this.order.CreatedById,
            activationUser:"AccountCommercialePRM", //Capire se da scablare e se inserire user o account, in attesa verifica M.Tatti
            account:"AccountCommercialePRM", //Capire se da scablare e se inserire user o account, in attesa verifica M.Tatti
            jobTitle:this.order.Channel__c,
            internalCustomerId:this.order.Account.CustomerCode__c,
            companyName:companyName,
            externalCustomerId:this.order.Account.FiscalCode__c,
            secondaryCustomerId:secondaryCustomerId,
            bpClass:this.order.Account.CustomerMarking__c, //modificare stringa da mandare, in attesa verifica M.Tatti
            bpCategory:this.order.Account.Category__c,
            bpType:bpType,
            customerType:"CT0",        
            operation:operation,
            companyGroup:this.order.SalesCompany__c, //OK
            market:market,
            offerType:offerType,
            details:[{
                commodity:typeOfCommodity
            }]		 
        }

        if(this.selectedProcessObject.recordType !== 'HDT_RT_VAS'){
            data["address"] = this.order.ServicePoint__r.SupplyStreetName__c;
            data["municipality"] = this.order.ServicePoint__r.SupplyCity__c;
            data["district"] = this.order.ServicePoint__r.SupplyProvince__c;
            data["postCode"] = this.order.ServicePoint__r.SupplyPostalCode__c;

            data["details"]["annualConsumption"] = this.order.ServicePoint__r.AnnualConsumptionStandardM3__c;
        }
        

        if(this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'){
            
            if(this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale'){
                fiscalData = this.order.ServicePoint__r.Account__r.FiscalCode__c;
            }else if(this.order.ServicePoint__r.Account__r.VATNumber__c != null){
                fiscalData = this.order.ServicePoint__r.Account__r.VATNumber__c;
            }
            
            data["bpAlternative"] = this.order.ServicePoint__r.Account__r.CustomerCode__c;
            data["alternativeCustomerId"] = fiscalData;            
        }

        return data; 
    }
    // END @Picchiri 07/06/21 Credit Check
    checkCompatibilityProcess(){
        this.loaded = false;
        let sRequest= {
            'servicePoint': this.order.ServicePoint__c,
            'servicePointCode': this.order.ServicePoint__r.ServicePointCode__c,
            'status': this.order.Status,
            'order': this.order.Id,
            'commoditySector': this.order.ServicePoint__r.CommoditySector__c,
            'type': 'Order',
            'processType' : this.selectedProcessObject.processType
        };
        checkCompatibility({servReq: sRequest}).then(data =>{
            if(data.compatibility == ''){
                this.applySelectionLogic(this.selectedProcessObject);
                this.serviceRequest= data.ServiceRequest;
            }else{
                this.incompatibilityfound(this.selectedProcessObject, data.compatibility);
            }
            this.loaded = true;

        }).catch(error => {
            this.loaded = true;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
            this.loaded = true;
        });
    }
}