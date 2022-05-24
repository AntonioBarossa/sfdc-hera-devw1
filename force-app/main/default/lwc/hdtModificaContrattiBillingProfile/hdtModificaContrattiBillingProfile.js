import { LightningElement, api } from 'lwc';
import  BillingProfileForm  from 'c/hdtBillingProfileForm';
import updateCase from '@salesforce/apex/HDT_LC_ModificaContrattiBp.updateBpDataOnCase';
import populateBpData from '@salesforce/apex/HDT_LC_ModificaContrattiBp.filterDataToBp';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import SystemCapacity__c from '@salesforce/schema/Case.SystemCapacity__c';



export default class hdtModificaContrattiBillingProfile extends BillingProfileForm {
    //input Properties
    @api theCase;
    @api account;
    @api accountId;

    @api availableActions = [];


    //output Properties
    @api cancelCase;
    @api saveInDraft;


    get signatoryTypeOptions() {
        let options = [
            { label: 'Pagatore Alternativo', value: 'Pagatore Alternativo' }
        ];

        if (this.theCase.Account.Category__c === 'Famiglie' 
            || this.theCase.Account.Category__c === 'Parti comuni'
            || this.theCase.Account.Category__c === 'Ditta individuale') {
            options.push({ label: 'Stesso Sottoscrittore', value: 'Stesso Sottoscrittore' });
        } else if (this.theCase.Account.Category__c !== 'Famiglie' 
                    && this.theCase.Account.Category__c !== 'Parti comuni'
                    && this.theCase.Account.Category__c !== 'Ditta individuale') {
            options.push({ label: 'Legale Rappresentante', value: 'Legale Rappresentante' });
        }

        return options;
    }

    handlePaymentMethodSelect(event){
        this.loading = true;
        this.fatturazioneElettronicaFields = [];
        this.tipologiaIntestatarioFields = [];
        this.dataToSubmit[event.target.fieldName] = event.target.value;
        this.handleGetFormFields(event.target.value);
    }

    connectedCallback(){
        super.connectedCallback();
        this.theCase={...this.theCase, Account:this.account};
        //override metodo getClone per prepopolazione campi billing profile
        //console.log('TheCase >>> ' + JSON.stringify(this.theCase));
        console.log('Note__c >>> ' + this.theCase.Note__c);
        if(this.theCase.Note__c !== null && this.theCase.Note__c !== undefined && this.theCase.Note__c !== '')
        {
            console.log('### Before TryClone ###');
            this.tryClone();
            console.log('### After TryClone ###');
        }
    }

    handleWrapAddressObjectReverse(data)
    {

        console.log('### Inside Address Wrapper ###');
        console.log('### Data >>> ' + JSON.stringify(data));
        let addressWrapper = {};
        console.log('### Start Writing Obj ###')
        addressWrapper["Via"] = data["InvoicingStreetName__c"];
        addressWrapper["Comune"] = data["InvoicingCity__c"];
        addressWrapper["CAP"] = data["InvoicingPostalCode__c"];
        addressWrapper["Stato"] = data["InvoicingCountry__c"];
        addressWrapper["Provincia"] = data["InvoicingProvince__c"];
        addressWrapper["Estens.Civico"] = data["InvoicingStreetNumberExtension__c"];
        addressWrapper["Civico"] = data["InvoicingStreetNumber__c"];
        addressWrapper["Localita"] = data["InvoicingPlace__c"];

        console.log('### AddressWrapper >>> ' + JSON.stringify(addressWrapper));

        return addressWrapper;
    }
    handleWrapAddressObject(){
        this.template.querySelector('c-hdt-target-object-address-for-flow').validate();
    }

    handleAnnull(){
        this.cancelCase=true;
        this.handleGoNext();
    }

    handleConfirmDraft(){
        //this.handleSaveEvent();//per limiti tecnici l'indirizzo deve essere validato anche nel draft
        this.saveInDraft=true;
        this.checksAndSave();
    }

    handleSaveEvent(){
        console.log('save');
        this.cancelCase=false;
        this.saveInDraft=false;
        this.checksAndSave();
    }

    checksAndSave(){
        const targetObjectFlow =this.template.querySelector('c-hdt-target-object-address-for-flow');
        let validity=targetObjectFlow.validate();
        console.log('AddressValidity >>> ' + JSON.stringify(validity))
        if(validity.isValid === true){
            //jump address controls on parent lwc, we already done it on targetObjectFlow
            this.isForeignAddress=false;
            this.isVerifiedAddress=true;
            //end jump
            //this.dataToSubmit['Account__c'] = this.accountId;
            this.dataToSubmit['IbanCountry__c'] = this.dataToSubmit['PaymentMethod__c'] == 'RID' ? 'IT' : '';
            let isValidFields = this.validFields();
            console.log('*******validFields result= ************ ' + JSON.stringify(isValidFields));
            if(this.saveInDraft || isValidFields===true){
                this.loading = true;
                //vai con la popolazione order, this.dataToSubmit da trasformare in case
                //utilizza un metodo apex, controlla che il field api name sia nel case altrimenti lancia una auraExc
                //Crea metodo in JS che ti converte le api name da BP a Case
                console.log("isValid");
                let mapFieldValue = this.convertBpToCase();
                /* Address Fields */
                mapFieldValue = this.getAddressFields(mapFieldValue, targetObjectFlow.getAddress());
                console.log('#BpData >>> ' + JSON.stringify(mapFieldValue));
                updateCase({"bpData" : mapFieldValue, "caseId" : this.theCase.Id}).then(data=>{
                    this.loading = false;
                    return;
                    //this.handleGoNext();
                }).catch(error => {
                    this.loading = false;
        
                    let errorMessage = '';
    
                    if (error.body.message !== undefined) {
                        errorMessage = error.body.message;
                    } else if(error.message !== undefined){
                        errorMessage = error.message;
                    } else if(error.body.pageErrors !== undefined){
                        errorMessage = error.body.pageErrors[0].message;
                    }
    
                    console.log('Error: ', errorMessage);
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: errorMessage,
                        variant: 'error'
                    });
                    this.dispatchEvent(toastErrorMessage);
                });
            }else{
                const toastErrorMessageValidFields = new ShowToastEvent({
                    title: 'Errore',
                    message: isValidFields,
                    variant: 'error'
                });
                this.dispatchEvent(toastErrorMessageValidFields);
            }
        }else{
            targetObjectFlow.alert('Dati tabella', validity.errorMessage, 'error');
        }
    }

    tryClone(){
        //let map = this.convertCaseToBp();
        populateBpData({theCase:this.theCase}).then(data =>{
            //let map = data;

            console.log('### PrepoluatedMap >>> ' + JSON.stringify(data));
            const targetObjectFlow =this.template.querySelector('c-hdt-target-object-address-for-flow');

            if(data["InvoicingCity__c"] !== null && data["InvoicingCity__c"] !== undefined && data["InvoicingCity__c"] !== "")
            {
                let addressWrapper = this.handleWrapAddressObjectReverse(data);
                console.log('### PrepopulateAddress >>> ' + JSON.stringify(addressWrapper));
                targetObjectFlow.prepopulateAddress(addressWrapper);
            }

            this.cloneObject = data;
            this.dataToSubmit = this.cloneObject;
            delete this.dataToSubmit.Id;
            const modPagamento = this.template.querySelector("[data-id='PaymentMethod__c']");
            modPagamento.value=this.cloneObject.PaymentMethod__c;
            this.handleGetFormFields(this.cloneObject.PaymentMethod__c);
        }).catch(error => {
            this.loading = false;

            let errorMessage = '';

            if (error.body.message !== undefined) {
                errorMessage = error.body.message;
            } else if(error.message !== undefined){
                errorMessage = error.message;
            } else if(error.body.pageErrors !== undefined){
                errorMessage = error.body.pageErrors[0].message;
            }

            console.log('Error: ', error);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
        
    }

    /*
    convertCaseToBp(){
        let listFields = Object.keys(this.theCase);
        let bp = {...this.theCase};
        let map = new Map();
        listFields.forEach(el => {
            if(map.has(el)){
                bp[map.get(el)] = bp[el];
                delete bp[el];
            }
        });
        return bp;
    }
    */

    convertBpToCase(){
        let listFields = Object.keys(this.dataToSubmit);
        let data = {...this.dataToSubmit};
        let map = new Map();
        listFields.forEach(el => {
            if(map.has(el)){
                data[map.get(el)] = data[el];
                delete data[el];
            }
        });
        return data;
    }

    invertMap(){
        let mapBpToCase = this.getFieldsMapped();
        return new Map(Array.from(mapBpToCase, a => a.reverse()));
    }

    getFieldsMapped(){
        let mapBpToCase = new Map();//Bp Field -> Case Field
        mapBpToCase.set("PaymentMethod__c", "DocumentPaymentMethod__c");
        mapBpToCase.set("InvoiceEmailAddress__c", "InvoiceEmail__c");

        //mapBpToCase.set("DivergentSubject__c", "ContactId");
        //mapBpToCase.set("IbanCountry__c", "SupplyCountry__c");
        return mapBpToCase;
    }

    handleGoNext() {
        if(this.availableActions.find(action => action === 'NEXT')){

            const navigateNextEvent = new FlowNavigationNextEvent();

            this.dispatchEvent(navigateNextEvent);

        } else {

            const navigateFinish = new FlowNavigationFinishEvent();

            this.dispatchEvent(navigateFinish);
        }

    }

    getAddressFields(map, address)
    {
        console.log('### Address Fields >>> ' + JSON.stringify(address));

        map['InvoicingStreetName__c'] =address["Via"];
        map['InvoicingCity__c'] =address["Comune"];
        map['InvoicingPostalCode__c'] =address["CAP"];       
        map['InvoicingCountry__c'] =address["Stato"];
        map['InvoicingProvince__c'] =address["Provincia"];
        map['InvoicingStreetNumberExtension__c'] =address["Estens.Civico"];
        map['InvoicingStreetNumber__c'] =address["Civico"];
        map['InvoicingPlace__c'] = address["Localita"];

        return map;
    }

}