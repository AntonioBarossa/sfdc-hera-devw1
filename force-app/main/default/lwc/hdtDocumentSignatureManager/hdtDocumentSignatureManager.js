import { LightningElement,track,api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import previewDocumentFile from '@salesforce/apex/HDT_LC_DocumentSignatureManager.previewDocumentFile';
import getSignSendMode from '@salesforce/apex/HDT_LC_DocumentSignatureManager.getSignSendMode';
import handleContactPoint from '@salesforce/apex/HDT_LC_DocumentSignatureManager.handleContactPoint';
import TraderWithdrawalDate__c from '@salesforce/schema/Order.TraderWithdrawalDate__c';
import { getRecord } from 'lightning/uiRecordApi';
import CURRENT_USER_ID from '@salesforce/user/Id';
import LOGIN_CHANNEL from '@salesforce/schema/User.LoginChannel__c';
const sourceWithDefault = ['Agenzie','Agenzie SME','Business Agent'];
const signModeAgenzie = 'Contratto già firmato';
const sendModeAgenzie = 'Posta Cartacea';
export default class HdtDocumentSignatureManager extends NavigationMixin(LightningElement) {
    //ProcessType: Required. For Sale pass the subtype, for post sales pass the value of the CaseType
    //The variable is used to calculate Modalità Firma & Modalità Spedizione Combobox Values
    @track processType;
    //Source: Required. Pass the User Source (Call Center, Sportello). Used to calculate Modalità Firma & Modalità Spedizione Combobox Values
    @track source;
    //Phone: Required. Pass the Phone number
    @track phone;
    //Email: Required. Pass the Email.
    @track email;
    //Address: Required. This variable is a complex type Name - Value. Pass all the fields that compose an Address and the Complete Address.
    @track address;
    //AccountId: Required. Pass the Id of the Account. Used to retreive all the Account Address.
    @track loginSource;
    @track accountId;
    @track documents;
    @api params;
    @api disableinput;
    @api disableSignMode;
    buttonStatefulState = false;
    @track enableEdit = false;
    @track emailRequired;
    @track phoneRequired;
    @track addressRequired;
    @track enablePreview = false;
    @track context;
    @track recordId;
    @track quoteType;
    @track signMode;
    @track sendMode;
    @track returnWrapper;
    @track modalitaFirma;
    @track modalitaInvio;
    @track signSendMap;
    @track isModalOpen = false;
    @track showSpinner = false;
    @track showAddress = false;
    @track documents;
    @track tipoPlico='';
    @track showModalContact=false;
    @track contactPointInfo;
    @track requireSendMode=true;
    @track currentUserChannel;
    defautlAgenciesManagement;

    //@frpanico 07/09 added EntryChannel__c (Canale di Ingresso) to predefault SendMode
    @track entryChannel;

    @wire(getRecord,{recordId:CURRENT_USER_ID, fields:[LOGIN_CHANNEL]})
    wiredUser({error, data})
    {
        if(error) console.log('### Unable to fetch user data');
        else if(data) this.currentUserChannel = data.fields.LoginChannel__c.value;
    }


    @api
    signModeDefault(){
        return this.template.querySelector("lightning-combobox[data-id=modalitaFirma]").value;
    }

    @api
    computeAgenciesDefault(setDefault){
        //eseguo il predefault
        let sourceNeedsDefault = false;
        sourceWithDefault.forEach((element => {
            if (element.localeCompare(this.source) === 0){
                sourceNeedsDefault = true;
            }
        }));
        if (this.defautlAgenciesManagement && this.source && sourceNeedsDefault && setDefault){
            let defaultSignModeForAgenzie = this.signSendMap.find((element) => (element.signMode === signModeAgenzie));
            this.template.querySelector("lightning-combobox[data-id=modalitaFirma]").value = defaultSignModeForAgenzie.signMode;
            this.modalitaInvio = defaultSignModeForAgenzie.sendMode;
            let defaultSendModeAgenzie = this.modalitaInvio.find((element) => (element.value === sendModeAgenzie));
            this.sendMode = defaultSendModeAgenzie.value;
        }
    }

    get disableSignModeInternal(){
        return this.disableSignMode === true || this.disableinput === true;
    }

    connectedCallback(){
        try{
            if(this.params){
                this.returnWrapper = JSON.parse(this.params);
                var inputWrapper = JSON.parse(this.params);
                this.documents = inputWrapper.documents;
                this.context = inputWrapper.context;
                this.recordId = inputWrapper.recordId;
                this.processType = inputWrapper.processType;
                this.source = inputWrapper.source;
                this.loginSource = inputWrapper.loginSource;
                this.phone = inputWrapper.phone;
                this.email = inputWrapper.email;
                this.accountId = inputWrapper.accountId;
                this.documents = inputWrapper.documents;
                this.quoteType = inputWrapper.quoteType;//var addressWrapper = JSON.parse(inputWrapper.addressWrapper);
                this.address = inputWrapper.addressWrapper.completeAddress;
                this.signMode = inputWrapper.signMode;
                this.sendMode = inputWrapper.sendMode;
                this.entryChannel = inputWrapper.entryChannel;
                this.defautlAgenciesManagement = false;

                if(this.signMode === 'Vocal Order' && this.processType === 'Modifica Privacy'){
                    this.requireSendMode = false;
                    this.emailRequired = false;
                }
                if (inputWrapper.checkAgencies && inputWrapper.checkAgencies.localeCompare('Y') === 0){
                    this.defautlAgenciesManagement = true;
                }
                let setDefault = false;
                if (inputWrapper.setDefault === true){
                    setDefault = true;
                }
                if(this.disableSignMode === true){
                    this.signMode = 'Cartacea'; // Pre-default se la modalità di firma viene disabilitata.
                    inputWrapper.signMode = 'Cartacea'; // Modifichiamo anche inputWrapper.signMode poichè è usato dopo in this.signSendMap.find() 
                    console.log('predefault sign mode: ' +  this.signMode);
                }
                if(inputWrapper.tipoPlico){
                    this.tipoPlico = inputWrapper.tipoPlico;
                }
                if(inputWrapper.enableEdit){
                    this.enableEdit = true;
                }
                if(this.context.localeCompare('Order') === 0 || (this.quoteType != null && this.quoteType != ''  && this.quoteType.localeCompare('Analitico') === 0)){
                    console.log('Inside if');
                    this.enablePreview = false;
                }else{
                    this.enablePreview = true;
                }
                if(this.context.localeCompare('EC')===0 || this.context.localeCompare('GC')===0){
                    this.showAddress = false;
                }else{
                    this.showAddress = true;
                }
                this.addressWrapper = inputWrapper.addressWrapper;
                getSignSendMode({
                    processType: this.processType,
                    source: this.source,
                }).then(result => {
                    console.log('getSignSendMode result ' + result);
                    var resultJSON = JSON.parse(result);
                    var signMode = [];
                    var sendMode = [];
                    var signSendMode;
                    var signSendModeList = [];
                    var existContrattoFirmato = false;
                    let existCartacea = false;
                    resultJSON.forEach((element) => {
                        signMode.push(element.signMode);
                        console.log('#element >>> ' + JSON.stringify(element.signMode));
                        if(element.signMode.value === 'Contratto già firmato'){
                            existContrattoFirmato = true;
                        }
                        if(element.signMode.value === 'Cartacea') existCartacea = true;
                        element.sendMode.forEach((element2) => {
                            sendMode.push(element2);
                        });
                        signSendMode = {
                            signMode : element.signMode.value,
                            sendMode : sendMode
                        };
                        signSendModeList.push(signSendMode);
                        sendMode = [];
                    });
                    if(this.loginSource != null && this.loginSource.localeCompare('Back office') === 0 && this.context.localeCompare('Order') === 0 && !existContrattoFirmato){
                        console.log('##inside backoffice');
                        sendMode = [];
                        const obj = {value: 'Stampa Cartacea', label: 'Stampa Cartacea'};
                        sendMode.push(obj);
                        signSendMode = {
                            signMode : 'Contratto già firmato',
                            sendMode : sendMode
                        };
                        const obj2 = {value: 'Contratto già firmato', label: 'Contratto già firmato'};
                        signMode.push(obj2);
                        signSendModeList.push(signSendMode);
                    }
                    console.log('### Before Sportello Excepion');
                    if(!existCartacea && this.currentUserChannel && this.currentUserChannel === 'Sportello')
                    {
                        console.log('### Start Sportello Excepion');
                        sendMode = [];
                        const obj = {value: 'Stampa Cartacea', label: 'Stampa Cartacea'};
                        sendMode.push(obj);
                        signSendMode = {
                            signMode : 'Cartacea',
                            sendMode : sendMode
                        };
                        const obj2 = {value: 'Cartacea', label: 'Cartacea'};
                        signMode.push(obj2);
                        signSendModeList.push(signSendMode);
                        console.log('### End Sportello Excepion');
                    }
                    console.log('### After Sportello Excepion');
                    this.signSendMap = signSendModeList; 
                    this.modalitaFirma = signMode;
                    console.log('this.signSendMap ' + JSON.stringify( this.signSendMap));
                    console.log('SEND_MODE >>> ' + this.sendMode);
                    console.log('ENTRY_CHANNEL >>> ' +this.entryChannel);
                    if(this.entryChannel !== null && this.entryChannel !== '' && this.entryChannel !== undefined)
                    {
                        if(this.entryChannel === 'Email')
                        {
                            console.log('>>> EMAIL_CONDITION <<<');
                            this.sendMode = 'E-Mail';
                            inputWrapper.sendMode = 'E-Mail';
                        }
                        else if(this.entryChannel !== 'PEC' && this.entryChannel !== 'Email')
                        {
                            console.log('>>> POSTA_CONDITION <<<');
                            this.sendMode = 'Posta Cartacea';
                            inputWrapper.sendMode = 'Posta Cartacea';
                        }
                    }
                    try{
                        if(this.signMode != null && this.signMode != ''){
                            console.log('IN: looking for ' + inputWrapper.signMode)
                            var temp = this.signSendMap.find(function(post, index) {
                                if(post.signMode == inputWrapper.signMode)
                                    return true;
                            });
                            console.log('out ' + JSON.stringify(temp));
                            if (temp){
                                this.modalitaInvio = temp.sendMode;
                            }
                            this.sendMode = inputWrapper.sendMode;
                        } else if (this.defautlAgenciesManagement){
                            this.computeAgenciesDefault(setDefault);
                        }
                        this.launchSetRequiredFieldEvent(false);
                    }catch(error){
                        console.error(error);
                    }
                    
                })
                .catch(error => {
                    console.log('errore ' +error.body.message);
                });
                
            }else{
                console.log('Params Null');
            }
        }catch (error) {
            console.error(error);
        }
    }

    handleChangeAddress(event){
        this.isModalOpen = !this.isModalOpen;
    }

    handleCloseModalContact(event){
        this.showModalContact = false;
        this.disableinput=false;
    }
    handleCloseModal(event){
        
        var addressWrapper = this.template.querySelector('c-hdt-target-object-address-fields').handleAddressFields();
        console.log(JSON.stringify(addressWrapper));
        if((addressWrapper['Flag Verificato']) && addressWrapper.Via != null && addressWrapper.Via != ""){
            console.log('New Address');
            this.handleNewAddress();
            this.isModalOpen = false;
        }else if(addressWrapper.Via == null || addressWrapper.Via==""){
            this.isModalOpen = false;
            console.log('No change');
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore',
                    message:'Attenzione! Seleziona un indirizzo valido.',
                    variant: 'error',
                }),
            );
        }
        
    }
    handleNewAddress() {
        try{
            var addressWrapper = this.template.querySelector('c-hdt-target-object-address-fields').handleAddressFields();
            var estensioneCivico = ((addressWrapper.EstensCivico)? addressWrapper['Estens.Civico']:'');
            this.address = addressWrapper.Via + ' ' + addressWrapper.Civico + ' ' + estensioneCivico + ', ' + addressWrapper.Comune + ' ' + addressWrapper.Provincia + ', ' + addressWrapper.CAP + ' ' +addressWrapper.Stato;
            this.returnWrapper.addressWrapper.CAP = addressWrapper.CAP;
            this.returnWrapper.addressWrapper.Civico = addressWrapper.Civico;
            this.returnWrapper.addressWrapper.CodiceComuneSAP = addressWrapper.CodiceComuneSAP;
            this.returnWrapper.addressWrapper.CodiceViaStradarioSAP = addressWrapper.CodiceViaStradarioSAP;
            this.returnWrapper.addressWrapper.Comune = addressWrapper.Comune;
            this.returnWrapper.addressWrapper.EstensCivico = addressWrapper['Estens.Civico'];
            this.returnWrapper.addressWrapper.FlagVerificato = addressWrapper['Flag Verificato'];
            //this.returnWrapper.addressWrapper. = addressWrapper.
            this.returnWrapper.addressWrapper.Provincia = addressWrapper.Provincia;
            this.returnWrapper.addressWrapper.Stato = addressWrapper.Stato;
            //this.returnWrapper.addressWrapper. = addressWrapper.
            this.returnWrapper.addressWrapper.Via = addressWrapper.Via;
            this.returnWrapper.addressWrapper.completeAddress = this.address;
        }catch(error){
            console.error(error);
        }
    }

    checkRequired(){
        try{
            var modFirma = this.template.querySelector("lightning-combobox[data-id=modalitaFirma]").value;
            var modSpedizione = this.template.querySelector("lightning-combobox[data-id=modalitaSpedizione]").value;
            console.log('modalità firma: ' + modFirma);
            console.log('modalità spedizione: ' + modSpedizione);
            if (modFirma == null){
                modFirma = '';
            }
            if (modSpedizione == null){
                modSpedizione = '';
            }
            if(modFirma.localeCompare('Vocal Order')===0 && this.processType != null && this.processType === 'Modifica Privacy'){
                this.emailRequired = false;
                this.phoneRequired = false;
                this.addressRequired = false;
            }else if(modFirma.localeCompare('OTP Coopresenza')===0 || modFirma.localeCompare('OTP Remoto')===0){
                this.emailRequired = true;
                this.phoneRequired = true;
                this.addressRequired = false;
            }else if(modSpedizione.localeCompare('Stampa Cartacea')===0){
                this.emailRequired = false;
                this.phoneRequired = false;
                this.addressRequired = true;
            }else if(modSpedizione.localeCompare('E-Mail')===0){
                this.phoneRequired = false;
                this.addressRequired = false;
                this.emailRequired = true;
            }else if(modSpedizione.localeCompare('Posta Cartacea')===0){
                this.emailRequired = false;
                this.phoneRequired = false;
                this.addressRequired = true;
            }else{
                this.phoneRequired = false;
                this.addressRequired = false;
                this.emailRequired = false;
            }
        }catch (error) {
            console.error(error);
        }
    }

    handleChange(event){
        this.checkRequired();
    }
    handleChangeSignMode(event){
        try{
            this.sendMode = null;
            this.dispatchEvent(new CustomEvent('changesignmode', { detail: event.detail.value}));
            var temp = this.signSendMap.find(function(post, index) {
                if(post.signMode == event.detail.value)
                    return true;
            });
            console.log(JSON.stringify(temp));
            this.modalitaInvio = temp.sendMode;
            console.log('Mod Invio ' + this.modalitaInvio);
            if(event.detail.value === 'Vocal Order' && this.processType != null && this.processType === 'Modifica Privacy'){
                this.requireSendMode = false;
                this.emailRequired = false;
            }
            console.log('mod invio ' + this.modalitaInvio);
            this.phoneRequired = false;
            this.addressRequired = false;
            this.emailRequired = false;
            this.checkRequired();
            let resetDate = true;
            if (event.detail.value.localeCompare(signModeAgenzie) === 0){
                resetDate = false;
            }
            this.launchSetRequiredFieldEvent(resetDate);
            
        }catch(error){
            console.error(error);
        }
        
    }
    @api
    checkForm(){
        try{
            var modFirma = this.template.querySelector("lightning-combobox[data-id=modalitaFirma]");
            var modSpedizione = this.template.querySelector("lightning-combobox[data-id=modalitaSpedizione]");
            var telefono = this.template.querySelector("lightning-input[data-id=telefono]");      
            var email =this.template.querySelector("lightning-input[data-id=email]");      
            var address = this.template.querySelector("lightning-input[data-id=indirizzoRecapito]");
            
            const comboValid = [...this.template.querySelectorAll('lightning-combobox')]
                .reduce((validSoFar, inputCmp) => {
                            inputCmp.reportValidity();
                            return validSoFar && inputCmp.checkValidity();
                }, true);
                if(!comboValid){
                    console.log('KO');
                    
                }else{
                    const allValid = [...this.template.querySelectorAll('lightning-input')]
                    .reduce((validSoFar, inputCmp) => {
                                inputCmp.reportValidity();
                                return validSoFar && inputCmp.checkValidity();
                    }, true);
                    if(!allValid){
                        console.log('KO');
                    }else{
                        console.log('OK');
                        this.buttonStatefulState = !this.buttonStatefulState
                        this.enableEdit = this.buttonStatefulState;
                        this.disableinput = true;
                        this.returnWrapper.signMode = modFirma.value;
                        this.returnWrapper.sendMode = modSpedizione.value;
                        this.returnWrapper.phone = telefono.value;
                        this.returnWrapper.email = email.value;
                        this.returnWrapper.addressWrapper.completeAddress = address.value;
                        this.returnWrapper.dataConfirmed = true;
                        //this.dispatchEvent(new CustomEvent('confirmdata', { detail: JSON.stringify(this.returnWrapper)}));
                        this.checkContactPoint();
                    }
                }
        }catch (error) {
            console.error(error);
        }
    }

    checkContactPoint(){
        console.log('### ' +this.returnWrapper.email);
        console.log('### ' +this.returnWrapper.phone);
        console.log('### ' +this.returnWrapper.contactId);
        console.log('### ' +this.returnWrapper.leadId);
        if(this.returnWrapper.contactId !== '' && this.returnWrapper.contactId !== undefined && this.returnWrapper.leadId !== undefined && this.returnWrapper.leadId !== null){
            let contactId = this.returnWrapper.leadId !== undefined && this.returnWrapper.leadId !== '' ? this.returnWrapper.leadId : this.returnWrapper.contactId;
            console.log('### contactId' + contactId); 
            handleContactPoint({
                email: this.returnWrapper.email,
                phone: this.returnWrapper.phone,
                contactId:contactId,
                mode:'query'
            }).then(result => {
                this.contactPointInfo = JSON.parse(result);
                console.log('#RESULT >>> ' + JSON.stringify(this.contactPointInfo));
                if(this.contactPointInfo.result ==='OK'){
                    this.dispatchEvent(new CustomEvent('confirmdata', { detail: JSON.stringify(this.returnWrapper)}));
                }else{
                    this.showModalContact = true;
                }
            })
        }
        else{
            this.dispatchEvent(new CustomEvent('confirmdata', { detail: JSON.stringify(this.returnWrapper)}));
        }
        
    }
    createContactPoint(){
        var email = '';
        var phone = '';
        if(this.contactPointInfo.email === 'KO'){
            email = this.returnWrapper.email;
        }
        if(this.contactPointInfo.phone === 'KO'){
            phone = this.returnWrapper.phone;
        }
        let contactId = this.returnWrapper.leadId !== undefined && this.returnWrapper.leadId !== '' ? this.returnWrapper.leadId : this.returnWrapper.contactId;
        console.log('### contactId' + contactId); 
        handleContactPoint({
            email: email,
            phone: phone,
            contactId:contactId,
            mode:'insert'
        }).then(result => {
            console.log('result' + result);
            if(result ==='OK'){
                this.showModalContact = false;
                this.dispatchEvent(new CustomEvent('confirmdata', { detail: JSON.stringify(this.returnWrapper)}));
            }else{
                this.showMessage('Attenzione','Errore nella creazione dei contact point','error');
                this.showModalContact = false;
            }
        }).catch(error => {
            console.log('error ' + error);
            this.showMessage('Attenzione','Errore nella creazione dei contact point','error');
            this.showModalContact = false;
        });
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

    handleButtonStatefulClick() {
        if(!this.buttonStatefulState){
            this.checkForm();
        }else{
            this.buttonStatefulState = !this.buttonStatefulState
            this.enableEdit =this.buttonStatefulState;
            this.returnWrapper.dataConfirmed = false;
            this.dispatchEvent(new CustomEvent('confirmdata', { detail: JSON.stringify(this.returnWrapper)}));
        }  

    }
    @api
    handlePreview(){
        try{
            this.showSpinner = true;
            var formParams = {
                sendMode : this.template.querySelector("lightning-combobox[data-id=modalitaSpedizione]").value,
                signMode : this.template.querySelector("lightning-combobox[data-id=modalitaFirma]").value,
                telefono : this.template.querySelector("lightning-input[data-id=telefono]").value,      
                email : this.template.querySelector("lightning-input[data-id=email]").value,      
                //address : this.template.querySelector("lightning-input[data-id=indirizzoRecapito]").value,
                mode : 'Preview',
                Archiviato : 'N',
                EstrattoConto:this.documents,
                TipoPlico:this.tipoPlico
            };
            
            previewDocumentFile({
                recordId: this.recordId,
                context: this.context,
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
                    }else{
                        this.showSpinner = false;
                        // WORKAROUND per far avanzare il processo anche in caso di plico non stampato.
                        //this.dispatchEvent(new CustomEvent('previewexecuted'));
                        this.showMessage('Attenzione',resultParsed.message,'error');
                    }
                }else{
                    this.showSpinner = false;
                    // WORKAROUND per far avanzare il processo anche in caso di plico non stampato.
                    //this.dispatchEvent(new CustomEvent('previewexecuted'));
                    this.showMessage('Attenzione','Errore nella composizione del plico','error');
                }
            })
            .catch(error => {
                this.showSpinner = false;
                console.error(error);
            });
        }catch(error){
            console.error();
        }
    }

    launchSetRequiredFieldEvent(resetDate){
        if (this.defautlAgenciesManagement){
            this.dispatchEvent(new CustomEvent('setrequiredfield',{detail: resetDate}));
        }
    }
}