import { LightningElement,track,api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PHONE_FIELD from '@salesforce/schema/Case.PhoneNumber__c';
import EMAIL_FIELD from '@salesforce/schema/Case.Email__c';
import ADDRESS_FIELD from '@salesforce/schema/Case.DeliveryAddress__c';
import ID_FIELD from '@salesforce/schema/Case.Id';
import MOD_FIRMA from '@salesforce/schema/Case.SignMode__c';
import MOD_INVIO from '@salesforce/schema/Case.SendMode__c';
import InvoicingPostalCode from '@salesforce/schema/Case.InvoicingPostalCode__c';
import InvoicingStreetNumber from '@salesforce/schema/Case.InvoicingStreetNumber__c';
import InvoicingCityCode from '@salesforce/schema/Case.InvoicingCityCode__c';
import InvoicingStreetCode from '@salesforce/schema/Case.InvoicingStreetCode__c';
import InvoicingCity from '@salesforce/schema/Case.InvoicingCity__c';
import InvoicingStreetNumberExtension from '@salesforce/schema/Case.InvoicingStreetNumberExtension__c';
import IsInvoicingVerified from '@salesforce/schema/Case.IsInvoicingVerified__c';
import InvoicingPlace from '@salesforce/schema/Case.InvoicingPlace__c';
import InvoicingStreetName from '@salesforce/schema/Case.InvoicingStreetName__c';
import InvoicingCountry from '@salesforce/schema/Case.InvoicingCountry__c';
import InvoicingProvince from '@salesforce/schema/Case.InvoicingProvince__c';
import Origin from '@salesforce/schema/Case.Origin';
import SignMode from '@salesforce/schema/Case.SignMode__c';
import AddressFormula from '@salesforce/schema/Case.AddressFormula__c';
import sendDocument from '@salesforce/apex/HDT_LC_DocumentSignatureManager.sendDocumentFile';
import previewDocumentFile from '@salesforce/apex/HDT_LC_DocumentSignatureManager.previewDocumentFile';
import { NavigationMixin } from 'lightning/navigation';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import updateContactForScartoDocumentale from '@salesforce/apex/HDT_UTL_Scarti.updateContactForScartoDocumentale'; //costanzo.lomele@webresults.it 31/08/21 - aggiornamento dati su contatto
import getFlowCase from '@salesforce/apex/HDT_SRV_ScriptManager.getFlowCase';
const FIELDS = ['Case.ContactMobile', 
                'Case.ContactEmail',
                'Case.DeliveryAddress__c',
                'Case.Email__c',
                'Case.PhoneNumber__c', 
                'Case.BillingProfile__c',
                'Case.SignMode__c',
                'Case.SendMode__c',
                'Case.Account.BillingStreetName__c',
                'Case.Account.BillingStreetNumber__c',
                'Case.Account.BillingCity',
                'Case.Account.BillingState',
                'Case.Account.BillingPostalCode',
                'Case.Account.BillingCountry',
                'Case.Account.BillingAddressFormula__c',
                'Case.Account.BillingCityCode__c',
                'Case.Account.BillingStreetNumberExtension__c',
                'Case.Account.BillingStreetCode__c',
                'Case.InvoicingPostalCode__c',
				'Case.InvoicingStreetNumber__c',
				'Case.InvoicingCityCode__c',
				'Case.InvoicingStreetCode__c',
				'Case.InvoicingCity__c',
				'Case.InvoicingStreetNumberExtension__c',
				'Case.IsInvoicingVerified__c',
				'Case.InvoicingPlace__c',
				'Case.InvoicingStreetName__c',
				'Case.InvoicingCountry__c',
                'Case.InvoicingProvince__c',
                'Case.Origin',
                'Case.ContactId'];

export default class HdtDocumentSignatureManagerFlow extends NavigationMixin(LightningElement) {
    
    //START>> costanzo.lomele@webresults.it 31/08/21 - aggiornamento dati su contatto
    oldPhoneValue;
    oldEmailValue;
    //END>> costanzo.lomele@webresults.it 31/08/21 - aggiornamento dati su contatto

    @api processType;
    @api quoteType;
    @api recordId;
    @api accountId;
    @api source;
    @api outcome;
    @api availableActions = [];
    @api cancelCase;
    @api nextLabel;
    @api nextVariant;
    @api documents;
    @api disableSignMode;
    @api cancelButton;
    //@frpanico 07/09 added EntryChannel
    @api entryChannel;
    //HRADTR_GV_Main
    @api discardRework;
    @api discardActivityId;
    caseRecord;
    @track inputParams;
    @track enableNext = false;
    @track previewExecuted = false;
    @track confirmData;
    @track labelConfirm = 'Conferma pratica';
    @track showConfirmButton = false;
    @track showPreviewButton = true;
    @track previousButton;
    @api
    get variantButton(){
        if(this.nextVariant != null && this.nextVariant !="" && this.nextVariant != "unedfined")
            return this.nextVariant;
        else 
            return "brand"
    }
    
    @api
    get labelButton(){
        if(this.nextLabel != null && this.nextLabel!="" && this.nextLabel != "unedfined")
        return this.nextLabel;
        else 
        return "Conferma Pratica"
    }
    /*get cancelButton()
    {
        if(this.cancelButton === null || this.cancelButton === undefined)
        {
            return true;
        }
    }*/
    oldSignMode = '';
    
    scriptAvailable = false;
    openModal = false;
    flowFound = false;
    isLoading = true;

    connectedCallback(){
        console.log('Origin: ' + Origin);
        console.log('SignMode: ' + SignMode);

        if(this.quoteType && (this.quoteType.localeCompare('Analitico') === 0 || this.quoteType.localeCompare('Predeterminabile') === 0)){
            this.labelConfirm = 'Conferma pratica';
            this.showPreviewButton = false;
            this.previewExecuted = true;
        }else{
            this.labelConfirm = 'Invia documenti';
        }
        /*
        if(!this.availableActions.find(action => action === 'BACK')){
            this.previousButton = false;
        }
        else
        {
            this.previousButton = true;
        }*/

    }
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
        wiredCase({ error, data }) {
            if (error) {
                
                let message = 'Unknown error';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    message = error.body.message;
                }
                console.log('data error ' + message);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading Case',
                        message,
                        variant: 'error',
                    }),
                );
            } else if (data) {
                console.log('data loaded');
                this.caseRecord = data;
                console.log(JSON.stringify(this.caseRecord.fields));
                var email = '';
                var phone = '';
                var cap='';
                var stato = '';
                var via='';
                var comune='';
                var provincia='';
                var civico='';
                var codiceComuneSAP='';
                var estensCivico='';
                var codiceViaStradarioSAP='';
                var flagForzato=false;
                var flagVerificato=false;
                var canale = '';

                var contactEmail = this.caseRecord.fields.ContactEmail.value;
                var caseEmail = this.caseRecord.fields.Email__c.value;
                if(caseEmail != null && caseEmail != '')
                    email = caseEmail;
                else
                    email = contactEmail;
                var contactPhone = this.caseRecord.fields.ContactMobile.value;
                var casePhone = this.caseRecord.fields.PhoneNumber__c.value;
                if(casePhone != null && casePhone != ''){
                    phone = casePhone;
                } else{
                    phone = contactPhone;
                }

                //START>> costanzo.lomele@webresults.it 31/08/21 - aggiornamento dati su contatto
                this.oldPhoneValue = phone;
                this.oldEmailValue = email;
                //END>> costanzo.lomele@webresults.it 31/08/21 - aggiornamento dati su contatto

                var completeAddress = '';
                var caseAddress = this.caseRecord.fields.DeliveryAddress__c.value;
                if(caseAddress != null && caseAddress != ''){
                    completeAddress = caseAddress;
                    stato = this.caseRecord.fields.InvoicingCountry__c.value;
                    provincia = this.caseRecord.fields.InvoicingProvince__c.value;
                    via  = this.caseRecord.fields.InvoicingStreetName__c.value;
                    cap = this.caseRecord.fields.InvoicingPostalCode__c.value;
                    comune  = this.caseRecord.fields.InvoicingCity__c.value;
                    civico  = this.caseRecord.fields.InvoicingStreetNumber__c.value;
                    codiceComuneSAP  = this.caseRecord.fields.InvoicingCityCode__c.value;
                    estensCivico = this.caseRecord.fields.InvoicingStreetNumberExtension__c.value;
                    codiceViaStradarioSAP  = this.caseRecord.fields.InvoicingStreetCode__c.value;
                    flagForzato  = false;
                    flagVerificato  = this.caseRecord.fields.IsInvoicingVerified__c.value
                } else if(this.caseRecord.fields.Account.value != null){
                    completeAddress = this.caseRecord.fields.Account.value.fields.BillingAddressFormula__c.value;
                    stato = this.caseRecord.fields.Account.value.fields.BillingCountry.value;
                    //provincia = this.caseRecord.fields.Account.value.fields..value;
                    via  = this.caseRecord.fields.Account.value.fields.BillingStreetName__c.value;
                    cap = this.caseRecord.fields.Account.value.fields.BillingPostalCode.value;
                    comune  = this.caseRecord.fields.Account.value.fields.BillingCity.value;
                    civico  = this.caseRecord.fields.Account.value.fields.BillingStreetNumber__c.value;
                    codiceComuneSAP  = this.caseRecord.fields.Account.value.fields.BillingCityCode__c.value;
                    estensCivico = this.caseRecord.fields.Account.value.fields.BillingStreetNumberExtension__c.value;
                    codiceViaStradarioSAP  = this.caseRecord.fields.Account.value.fields.BillingStreetCode__c.value;
                    flagForzato  = false;
                    flagVerificato  = true;
                }
                var tempTipoPlico = '';
                // Gestione stampe da processo di piano rateizzazione
                // Se il flow passa ProcessType = 'RICH_RATEIZZAZIONE' mandiamo TipoPLico = 'RICH_RATEIZZAZIONE' e stampiamo i moduli di autorizzazione del piano rata.
                // Altrimenti mandiamo TipoPlico vuoto e stampiamo la normale ricevuta cliente.
                if (this.processType === 'RICH_RATEIZZAZIONE'){
                    tempTipoPlico = 'RICH_RATEIZZAZIONE';
                }
                var inputParams = {
                    dataConfirmed:false,
                    context:'Case',
                    recordId:this.recordId,
                    processType:this.processType,
                    source : this.source,
                    phone : phone,
                    email : email,
                    accountId : this.accountId,
                    quoteType : this.quoteType,
                    tipoPlico : tempTipoPlico,
                    entryChannel : this.entryChannel,
                    addressWrapper : {
                        completeAddress : completeAddress,
                        Stato : stato,
                        Provincia : provincia,
                        Via  : via,
                        CAP : cap,
                        Comune  : comune,
                        Civico  : civico,
                        CodiceComuneSAP  : codiceComuneSAP,
                        EstensCivico : estensCivico,
                        CodiceViaStradarioSAP  : codiceViaStradarioSAP,
                        FlagForzato  : flagForzato,
                        FlagVerificato  : flagVerificato
                    },
                    sendMode:this.caseRecord.fields.SendMode__c.value,
                    signMode:this.caseRecord.fields.SignMode__c.value,
                    contactId:this.caseRecord.fields.ContactId.value 
                }
                canale = this.caseRecord.fields.Origin.value;
                if( canale === 'Telefono Inbound' || canale === 'Telefono Outbound'){
                    this.scriptAvailable = true;
                }

                this.inputParams = JSON.stringify(inputParams);
                this.oldSignMode = this.caseRecord.fields.SignMode__c.value;
                console.log(this.inputParams);
            }
        }
    handlePreviewExecuted(event){
        this.previewExecuted = true;
    }

    handlePreview(event){
        let returnValue = this.template.querySelector('c-hdt-document-signature-manager').handlePreview();
    }

    sendAndViewDocument(formParams){
        previewDocumentFile({
            recordId: this.recordId,
            context: 'Case',
            formParams: JSON.stringify(formParams)
        }).then(result => {
            var resultParsed = JSON.parse(result);
            if(resultParsed.code === '200' || resultParsed.code === '201'){
                if(resultParsed.result === '000'){
                    var base64 = resultParsed.base64;
                    var sliceSize = 512;
                    var byteCharacters = window.atob(base64);
                    var byteArrays = [];

                    for ( var offset = 0; offset < byteCharacters.length; offset = offset + sliceSize ) {
                        var slice = byteCharacters.slice(offset, offset + sliceSize);
                        var byteNumbers = new Array(slice.length);
                        for (var i = 0; i < slice.length; i++) {
                            byteNumbers[i] = slice.charCodeAt(i);
                        }
                        var byteArray = new Uint8Array(byteNumbers);

                        byteArrays.push(byteArray);
                    }

                    this.blob = new Blob(byteArrays, { type: 'application/pdf' });

                    const blobURL = URL.createObjectURL(this.blob);
                    this.url = blobURL;
                    this.fileName = 'myFileName.pdf';
                    this.showFile = true;
                    this.showSpinner = false;
                    this[NavigationMixin.Navigate](
                        {
                            type: 'standard__webPage',
                            attributes: {
                                url: blobURL
                            }
                        }
                    );
                    this.dispatchEvent(new CustomEvent('previewexecuted'));
                    this.handleGoNext();
                }else{
                    this.showSpinner = false;
                    this.showMessage('Attenzione',resultParsed.message,'error');
                    console.log('temp workaround in caso di plico non trovato'); // TODO REMOVE
                    this.handleGoNext();                                         // TODO REMOVE
                }
            }else{
                this.showSpinner = false;
                this.showMessage('Attenzione','Errore nella composizione del plico','error');
                console.log('temp workaround in caso di plico non trovato'); // TODO REMOVE
                this.handleGoNext();                                         // TODO REMOVE
            }
        })
        .catch(error => {
            this.showSpinner = false;
            console.error(error);
        });
    }

    handleConfirmData(event){
        console.log('dati confermati ' + event.detail);
        this.confirmData = event.detail;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        var resultWrapper = JSON.parse(event.detail);
        if(resultWrapper.dataConfirmed){
            var estensioneCivico = ((resultWrapper.addressWrapper.EstensCivico)? resultWrapper.addressWrapper.EstensCivico:'');
            var address = resultWrapper.addressWrapper.Via + ' ' + resultWrapper.addressWrapper.Civico + ' ' + estensioneCivico + ', ' + resultWrapper.addressWrapper.Comune + ' ' + resultWrapper.addressWrapper.Provincia + ', ' + resultWrapper.addressWrapper.CAP + ' ' +resultWrapper.addressWrapper.Stato;
            console.log('indirizzo completo ' +address);
            fields[PHONE_FIELD.fieldApiName] = resultWrapper.phone;
            fields[EMAIL_FIELD.fieldApiName] = resultWrapper.email;
            fields[ADDRESS_FIELD.fieldApiName] = address;
            fields[MOD_FIRMA.fieldApiName] = resultWrapper.signMode;
            fields[MOD_INVIO.fieldApiName] = resultWrapper.sendMode;
            fields[InvoicingPostalCode.fieldApiName] = resultWrapper.addressWrapper.CAP;
            fields[InvoicingStreetNumber.fieldApiName] = resultWrapper.addressWrapper.Civico;
            fields[InvoicingCityCode.fieldApiName] = resultWrapper.addressWrapper.CodiceComuneSAP;
            fields[InvoicingStreetCode.fieldApiName] = resultWrapper.addressWrapper.CodiceViaStradarioSAP;
            fields[InvoicingCity.fieldApiName] = resultWrapper.addressWrapper.Comune;
            fields[InvoicingStreetNumberExtension.fieldApiName] = resultWrapper.addressWrapper.EstensCivico;
            fields[IsInvoicingVerified.fieldApiName] = resultWrapper.addressWrapper['Flag Verificato'];
            //fields[InvoicingPlace.fieldApiName] = resultWrapper.addressWrapper.
            fields[InvoicingProvince.fieldApiName] = resultWrapper.addressWrapper.Provincia;
            fields[InvoicingCountry.fieldApiName] = resultWrapper.addressWrapper.Stato;
            fields[InvoicingStreetName.fieldApiName] = resultWrapper.addressWrapper.Via;

            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    //START>> costanzo.lomele@webresults.it 31/08/21 - aggiornamento dati su contatto
                    /*try {
                        updateContactForScartoDocumentale({accountId:this.accountId, 
                                                            oldPhone: this.oldPhoneValue,
                                                            oldEmail: this.oldEmailValue,
                                                            newPhone: resultWrapper.phone,
                                                            newMail: resultWrapper.email});
                    } catch (error) {
                      console.error('updateContactForScartoDocumentale exception: ',JSON.stringify(error));
                    }*/
                    //END>> costanzo.lomele@webresults.it 31/08/21 - aggiornamento dati su contatto
                    // Display fresh data in the form
                    console.log('Record aggiornato');
                    this.enableNext = true;
                    this.handleConfirm();
                    return refreshApex(this.wiredCase);
                })
                .catch(error => {
                    console.log('Errore in aggiornamento');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
            this.enableNext = true;
            
        }else{
            this.enableNext = false;
        }
    }
    handleConfirmButton(){
        let returnValue = this.template.querySelector('c-hdt-document-signature-manager').checkForm();
    }
    handleConfirm(){
        if(this.enableNext){
            if((!this.previewExecuted && this.quoteType && this.quoteType.localeCompare('Analitico') != 0)){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore',
                        message:'Attenzione! Devi effettuare la preview del documento prima di poter procedere con il Conferma Pratica.',
                        variant: 'error',
                    }),
                );
            }else if(this.quoteType && (this.quoteType.localeCompare('Analitico') === 0 || this.quoteType.localeCompare('Predeterminabile') === 0)){
                this.handleGoNext();
            }else{
                console.log('sendDocumentFile');
                this.sendDocumentFile();
            }
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore',
                    message:'Attenzione! Devi confermare i dati prima di procedere con il Conferma Pratica.',
                    variant: 'error',
                }),
            );
        }
    }
    handleGoNext(){
        if(this.availableActions.find(action => action === 'NEXT')){

            const navigateNextEvent = new FlowNavigationNextEvent();

            this.dispatchEvent(navigateNextEvent);

        } else {

            const navigateFinish = new FlowNavigationFinishEvent();

            this.dispatchEvent(navigateFinish);
        }
    }

    sendDocumentFile(){
        try{
            this.confirmData = JSON.parse(this.confirmData);
            var sendMode = this.confirmData.sendMode;
            if(sendMode.localeCompare('Stampa Cartacea')===0){
                sendMode = 'Sportello';
            }
            var tipoPlico = '';
            // Gestione stampe da processo di piano rateizzazione
            // Se il flow passa ProcessType = 'RICH_RATEIZZAZIONE' mandiamo TipoPLico = 'RICH_RATEIZZAZIONE' e stampiamo i moduli di autorizzazione del piano rata.
            // Altrimenti mandiamo TipoPlico vuoto e stampiamo la normale ricevuta cliente.
            if (this.processType === 'RICH_RATEIZZAZIONE'){
                tipoPlico = 'RICH_RATEIZZAZIONE';
            }
            var discardOldEnvelope = false;
            if (this.confirmData.signMode.localeCompare('OTP Remoto') === 0 && this.oldSignMode != null && this.oldSignMode.localeCompare('OTP Coopresenza') === 0){
                discardOldEnvelope = true;
            }
            var formParams = {
                sendMode : sendMode,
                signMode : this.confirmData.signMode,
                telefono : this.confirmData.telefono,      
                email : this.confirmData.email,
                TipoPlico : tipoPlico,
                mode : 'Print',
                Archiviato : 'Y',
                DiscardOldEnvelope : discardOldEnvelope,
                discardRework : this.discardRework,
                discardActivityId : this.discardActivityId
            }
            if(sendMode.localeCompare('Sportello') ===0){
                this.sendAndViewDocument(formParams);
            }else{
                sendDocument({
                    recordId: this.recordId,
                    context: 'Case',
                    formParams: JSON.stringify(formParams)
                }).then(result => {
                    this.handleGoNext();
                }).catch(error => {
                    this.showMessage('Errore nell\'invio del documento al cliente.','error');
                    console.error(error);
                });
            }
        }catch(error){
            console.error(error);
        }
    }

    handleCancel(){

        if(this.availableActions.find(action => action === 'NEXT')){

            this.cancelCase = true;
            

            const navigateNextEvent = new FlowNavigationNextEvent();

            this.dispatchEvent(navigateNextEvent);

        } else {

            const navigateFinish = new FlowNavigationFinishEvent();

            this.dispatchEvent(navigateFinish);
        }

    }

    handleGoBack(){

        if(!this.availableActions.find(action => action === 'BACK')){
            this.previousButton = false;
            showMessage('Attenzione','Non è possibile tornare indietro.','error')
        }else{
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
        }
        

    }

    showMessage(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            }),
        );
    }

    launchScript(){

        this.openModal = true;

        getFlowCase({caseId: this.recordId}).then(flowUrl => {
            console.log('flowUrl returned: ' + flowUrl);
            if (flowUrl !== null && flowUrl !== '' && flowUrl !== 'flow not found') {
                this.flowFound = true;
                this.flowUrl = flowUrl;
            }else{
                this.flowFound = false;
            }
    
            this.isLoading = false;
        },error => {
            console.log(error);
            const evt = new ShowToastEvent({
                title: 'Errore caricamento Script',
                message: 'Non è stato possibile recuperare le informazioni relative agli script',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        });
    }

    closeModal(){
        this.openModal = false;
        this.dispatchEvent(new CustomEvent('close'));
    }
}