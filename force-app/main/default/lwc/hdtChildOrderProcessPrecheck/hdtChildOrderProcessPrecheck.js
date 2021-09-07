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
    @track deliberation = '';
    showDeliberation = false;
    @track disabledDeliberation = false;
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
        // else if(selectedProcess.recordType === 'HDT_RT_Subentro')
        // {
        //     this.precheck = true;
        //     this.compatibilita = true;
        //     this.causale = '';
        //     this.showDeliberation = false;
        // }
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
        // else if(selectedProcess.recordType === 'HDT_RT_AttivazioneConModifica')
        // {
        //     this.precheck = true;
        //     this.compatibilita = true;
        //     this.causale = '';
        //     this.showDeliberation = false;
        // }
        else if(selectedProcess.recordType === 'HDT_RT_VAS')
        {
            this.selectedProcessObject.recordType = 'HDT_RT_VAS';
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        // else if(selectedProcess.recordType === 'HDT_RT_CambioOfferta')
        // {
        //     this.precheck = true;
        //     this.compatibilita = true;
        //     this.causale = '';
        //     this.showDeliberation = false;
        // }
        // else if(selectedProcess.recordType === 'HDT_RT_ScontiBonus')
        // {
        //     this.precheck = true;
        //     this.compatibilita = true;
        //     this.causale = '';
        //     this.showDeliberation = false;
        // }
        // else if(selectedProcess.recordType === 'HDT_RT_ConnessioneConAttivazione')
        // {
        //     this.precheck = true;
        //     this.compatibilita = true;
        //     this.causale = '';
        //     this.showDeliberation = false;
        // }
        // else if(selectedProcess.recordType === 'HDT_RT_TemporaneaNuovaAtt')
        // {
        //     this.precheck = true;
        //     this.compatibilita = true;
        //     this.causale = '';
        //     this.showDeliberation = false;
        // }
        // else if(selectedProcess.recordType === 'HDT_RT_CambioUso')
        // {
        //     this.precheck = true;
        //     this.compatibilita = true;
        //     this.causale = '';
        //     this.showDeliberation = false;
        // }
        //INIZIO SVILUPPI EVERIS
        else if(selectedProcess.recordType === 'HDT_RT_Voltura'){
            this.selectedProcessObject.recordType = 'HDT_RT_Voltura';
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        //FINE SVILUPPI EVERIS 
        else{
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;

        }
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
        // else if(selectedProcess.recordType === 'HDT_RT_Subentro')
        // {
        //     this.precheck = true;
        //     this.compatibilita = false;
        //     this.causaleCompatibilita = compatibility;
        //     this.showDeliberation = false;
        // }
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
        // else if(selectedProcess.recordType === 'HDT_RT_AttivazioneConModifica')
        // {
        //     this.precheck = true;
        //     this.compatibilita = false;
        //     this.causaleCompatibilita = compatibility;
        //     this.showDeliberation = false;
        // }
        else if(selectedProcess.recordType === 'HDT_RT_VAS')
        {
            this.selectedProcessObject.recordType = 'HDT_RT_VAS';
            this.precheck = true;
            this.compatibilita = false;
            this.causaleCompatibilita = compatibility;
            this.showDeliberation = false;
        }
        // else if(selectedProcess.recordType === 'HDT_RT_CambioOfferta')
        // {
        //     this.precheck = true;
        //     this.compatibilita = false;
        //     this.causaleCompatibilita = compatibility;
        //     this.showDeliberation = false;
        // }
        // else if(selectedProcess.recordType === 'HDT_RT_ScontiBonus')
        // {
        //     this.precheck = true;
        //     this.compatibilita = false;
        //     this.causaleCompatibilita = compatibility;
        //     this.showDeliberation = false;
        // }
        // else if(selectedProcess.recordType === 'HDT_RT_ConnessioneConAttivazione')
        // {
        //     this.precheck = true;
        //     this.compatibilita = false;
        //     this.causaleCompatibilita = compatibility;
        //     this.showDeliberation = false;
        // }
        // else if(selectedProcess.recordType === 'HDT_RT_TemporaneaNuovaAtt')
        // {
        //     this.precheck = true;
        //     this.compatibilita = false;
        //     this.causaleCompatibilita = compatibility;
        //     this.showDeliberation = false;
        // }
        // else if(selectedProcess.recordType === 'HDT_RT_CambioUso')
        // {
        //     this.precheck = true;
        //     this.compatibilita = false;
        //     this.causaleCompatibilita = compatibility;
        //     this.showDeliberation = false;
        // }
        //INIZIO SVILUPPI EVERIS
        else if(selectedProcess.recordType === 'HDT_RT_Voltura'){
            this.selectedProcessObject.recordType = 'HDT_RT_Voltura';
            this.precheck = true;
            this.compatibilita = false;
            this.causaleCompatibilita = compatibility;
            this.showDeliberation = false;
        }
        //FINE SVILUPPI EVERIS 

        else{
            this.precheck = true;
            this.compatibilita = false;
            this.causaleCompatibilita = compatibility;
            this.showDeliberation = false;
        }
    }

    handleSelectProcess(event){
        
        // if(event.target.value == 'Prima Attivazione In delibera') {
        //     console.log('handleSelectProcess: ' + JSON.stringify(event.detail.value));
        //     this.deliberation = 'In Delibera';
        //     this.disabledDeliberation = true;
        // }

        // if(event.target.value == 'Prima Attivazione Fuori delibera') {
        //     console.log('handleSelectProcess: ' + JSON.stringify(event.detail.value));
        //     this.deliberation = 'Fuori delibera';
        //     this.disabledDeliberation = true;
        // }

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
            if(data != ''){
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: 'Processo incompatibile!',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);

                this.incompatibilityfound(this.selectedProcessObject, data);
                this.loaded = true;
            }else{
                this.loaded = true;
                this.dispatchEvent(new CustomEvent('refreshorderchild'));
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
    }

    handleNext(){
        //@Picchiri 07/06/21 Credit Check Innesco per chiamata al ws
        /**
         * La chiamata al credit check va eseguita per queste condizioni
         * HDT_RT_Subentro , HDT_RT_AttivazioneConModifica, HDT_RT_SwitchIn (solo se process_type diverso da Switch In Ripristinatorio), 
         * HDT_RT_ConnessioneConAttivazione, HDT_RT_TemporaneaNuovaAtt, HDT_RT_Voltura, 
         * HDT_RT_VAS (Solo Se: OrderReference__c <> null & ContractReference <> null)
         */
         console.log('****12');
        if((this.selectedProcessObject.recordType === 'HDT_RT_VAS' && (this.order.OrderReferenceNumber == null || this.order.OrderReferenceNumber === undefined) && (this.order.ContractReference__c == null || this.order.ContractReference__c === undefined)) || this.selectedProcessObject.recordType === 'HDT_RT_Voltura' ||this.selectedProcessObject.recordType === 'HDT_RT_Subentro' || this.selectedProcessObject.recordType === 'HDT_RT_AttivazioneConModifica' || (this.selectedProcessObject.recordType === 'HDT_RT_SwitchIn' && this.order.ProcessType__c != 'Switch in Ripristinatorio') || this.selectedProcessObject.recordType === 'HDT_RT_ConnessioneConAttivazione' || this.selectedProcessObject.recordType === 'HDT_RT_TemporaneaNuovaAtt'){
            this.callCreditCheckSAP();
        }
        console.log('****13');
        

        let extraParams = {};

        if(this.order.ServicePoint__r !== undefined){
            extraParams['servicePointType'] = this.order.ServicePoint__r.RecordType.DeveloperName;
        }

        if(this.order.ProcessType__c === 'Switch in Ripristinatorio'){
            extraParams['switchInRipristinatorio'] = 'true';
        }
        console.log('****1');
        if (this.showDeliberation === true) {
            console.log('****2');
            if (this.deliberation !== '') {
                console.log('****4');
                this.goToNextStep(extraParams);
                this.disabledDeliberation = true;
            } else {
                console.log('****5');
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: 'Devi compilare il campo delibera.',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            }
        } else {
            console.log('****3');
            this.goToNextStep(extraParams);
        }

    }

    connectedCallback(){
        console.log('this.order: ', JSON.parse(JSON.stringify(this.order)));

        console.log('CallBack start');
        this.deliberation = this.order.Deliberation__c;

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
                    if(this.order.IsVAS__c){
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
                let toastErrorMessage = new ShowToastEvent({
                    title: 'CreditCheck KO',
                    message: result.errorDetails[0].code + ' ' + JSON.stringify(result.errorDetails[0].message),
                    variant: 'warning', 
                    mode:'dismissible'
                });
                this.dispatchEvent(toastErrorMessage);
                //throw {body:{message:result.errorDetails[0].code + ' ' + result.errorDetails[0].message}}
            }
            

            //this.restryEsitiCreditCheck();
            this.loading = false;
        })
        .catch(error => {
            debugger;
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
        let companyName = this.order.Account.FirstName__c? `${this.order.Account.FirstName__c} ${this.order.Account.LastName__c}` : this.order.Account.LastName__c;
        let companyGroup;
        var secondaryCustomerId = null;
        var bpType = null;
        var operation = null;
        var market = null; 
        var offerType = null; 
        let bpClass = null;
        console.log("RecordType: " + this.order.RecordType.DeveloperName);
        console.log("typeOfCommodity: " + typeOfCommodity);
        var fiscalData = null;

        if(this.selectedProcessObject.recordType !== 'HDT_RT_VAS'){
            if(this.order.ServicePoint__r.CommoditySector__c == 'Gas'){
                typeOfCommodity = 'GAS';
            }
        }
        if(this.order.SalesCompany__c !== undefined){
            companyGroup = this.order.SalesCompany__c;
        }
        if(this.order.Account.VATNumber__c !== undefined){
            secondaryCustomerId = this.order.Account.VATNumber__c;
        }
        if(this.order.Account.CustomerType__c !== undefined){
            bpType = this.order.Account.CustomerType__c;
        }
        if( this.selectedProcessObject.processType !== undefined){
            operation = this.selectedProcessObject.processType;
        }
        if(this.order.Market__c !== undefined){
            market = this.order.Market__c;
        }
        if(this.order.Catalog__c !== undefined){
            offerType = this.order.Catalog__c;
        }
        if(new RegExp("D[0-9] - ").test(this.order.Account.CustomerMarking__c)){
            bpClass=this.order.Account.CustomerMarking__c.replace(new RegExp("D[0-9] - "), "");
        }else{
            bpClass=this.order.Account.CustomerMarking__c;
        }
        console.log("typeOfCommodity: " + typeOfCommodity);
        console.log("this.selectedProcessObject: " + JSON.stringify(this.selectedProcessObject));
        
        let data = {
            sistema: "eEnergy",
            caso:"Transazionale",
            crmEntity:"Order",
            crmId:this.order.Id.slice(0,15),
            userId: this.order.CreatedById,
            activationUser:"AccountCommercialePRM", //this.order.Owner.Username (parte prima @)
            account:"AccountCommercialePRM", //this.order.Owner.Username (parte prima @)
            jobTitle:this.order.ChannelTransCode__c,
            internalCustomerId:this.order.Account.CustomerCode__c,
            companyName:companyName,
            externalCustomerId:this.order.Account.FiscalCode__c,
            secondaryCustomerId:secondaryCustomerId,
            bpClass:bpClass,
            bpCategory:this.order.Account.Category__c,
            bpType:bpType,
            customerType:"CT0", //da definire campo SF con business            
            operation:operation,
            companyGroup:companyGroup,//this.order.SalesCompany__c
            market:market,
            offerType:offerType,
            details:[{
                commodity:typeOfCommodity
            }]		
        }
        console.log("this.2"); 

        if(this.selectedProcessObject.recordType !== 'HDT_RT_VAS'){
            data["address"] = this.order.ServicePoint__r.SupplyStreetName__c;
            data["municipality"] = this.order.ServicePoint__r.SupplyCity__c;
            data["district"] = this.order.ServicePoint__r.SupplyProvince__c;
            data["postCode"] = this.order.ServicePoint__r.SupplyPostalCode__c;

            data["details"]["annualConsumption"] = this.order.ServicePoint__r.AnnualConsumptionStandardM3__c;
        }
        console.log("this.3"); 

        if(this.selectedProcessObject.recordType === 'HDT_RT_Subentro' || this.selectedProcessObject.recordType === 'HDT_RT_Voltura'){
            console.log("this.31:" + JSON.stringify(this.order.Account.RecordType.DeveloperName)); 
            console.log("this.310:" + JSON.stringify(this.order.ServicePoint__r)); 
            if(this.order.ServicePoint__r?.Account__r?.RecordType?.DeveloperName === 'HDT_RT_Residenziale'){
                console.log("this.32:"); 
                fiscalData = this.order.ServicePoint__r?.Account__r?.FiscalCode__c;
            }else if(this.order.ServicePoint__r?.Account__r?.VATNumber__c != null){
                console.log("this.33:"); 
                fiscalData = this.order.ServicePoint__r?.Account__r?.VATNumber__c;
            }
            console.log("this.34"); 
            
            data["bpAlternative"] = this.order.ServicePoint__r?.Account__r?.CustomerCode__c;
            data["alternativeCustomerId"] = fiscalData;
        }
        console.log("this.4"); 

        return data; 
    }
    // END @Picchiri 07/06/21 Credit Check
    checkCompatibilityProcess(){
        this.loaded = false;
        let sRequest= {
            'servicePoint': this.order.ServicePoint__c,
            'servicePointCode': this.order.ServicePoint__r?.ServicePointCode__c,
            'status': this.order.Status,
            'order': this.order.Id,
            'commoditySector': this.order.ServicePoint__r?.CommoditySector__c,
            'type': 'Order',
            'processType' : this.selectedProcessObject.processType
        };
        if(this.selectedProcessObject.processType=="VAS"){
            sRequest["isBillableVas"]=this.order.IsBillableVas__c;
        }
        checkCompatibility({servReq: sRequest}).then(data =>{
            if(data.compatibility == '' || data.compatibility == this.order.OrderNumber){
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