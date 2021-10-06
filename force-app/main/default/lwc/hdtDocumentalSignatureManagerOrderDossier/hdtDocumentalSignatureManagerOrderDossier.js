import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import controllerInit from '@salesforce/apex/HDT_LC_OrderDossierWizardSignature.controllerInit';
import next from '@salesforce/apex/HDT_LC_OrderDossierWizardSignature.next';
import edit from '@salesforce/apex/HDT_LC_OrderDossierWizardSignature.edit';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Order.Id';
import PhoneNumber from '@salesforce/schema/Order.PhoneNumber__c';
import ShippingMail from '@salesforce/schema/Order.ShippingMail__c';
import SignatureMethod from '@salesforce/schema/Order.SignatureMethod__c';
import DocSendingMethod from '@salesforce/schema/Order.DocSendingMethod__c';
import ShippingPostalCode from '@salesforce/schema/Order.ShippingPostalCode__c';
import ShippingStreetNumber from '@salesforce/schema/Order.ShippingStreetNumber__c';
import ShippingCityCode from '@salesforce/schema/Order.ShippingCityCode__c';
import ShippingStreetCode from '@salesforce/schema/Order.ShippingStreetCode__c';
import ShippingCity from '@salesforce/schema/Order.ShippingCity__c';
import ShippingStreetNumberExtension from '@salesforce/schema/Order.ShippingStreetNumberExtension__c';
import ShippingIsAddressVerified from '@salesforce/schema/Order.ShippingIsAddressVerified__c';
import ShippingProvince from '@salesforce/schema/Order.ShippingProvince__c';
import ShippingCountry from '@salesforce/schema/Order.ShippingCountry__c';
import ShippingStreetName from '@salesforce/schema/Order.ShippingStreetName__c';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import updateContactForScartoDocumentale from '@salesforce/apex/HDT_UTL_Scarti.updateContactForScartoDocumentale'; //costanzo.lomele@webresults.it 31/08/21 - aggiornamento dati su contatto
import getSignatureScript from '@salesforce/apex/HDT_LC_OrderDossierWizardSignature.getSignatureScript';//gabriele.rota@webresults.it | 2021-09-13 

const FIELDS = [
    'Order.Id',
    'Order.Status',
    'Order.ContractSigned__c',
    'Order.SignedDate__c',
    'Order.SignatureMethod__c',
    'Order.SignMode__c',
    'Order.DocSendingMethod__c',
    'Order.ShippingMail__c',
    'Order.PhoneNumber__c',
	'Order.CreatedBy.LoginChannel__c',
    'Order.ShippingCity__c',
    'Order.ShippingCityCode__c',
    'Order.ShippingCountry__c',
    'Order.ShippingPlace__c',
    'Order.ShippingPlaceCode__c',
    'Order.ShippingPostalCode__c',
    'Order.ShippingProvince__c',
    'Order.ShippingStair__c',
    'Order.ShippingStreetCode__c',
    'Order.ShippingStreetName__c',
    'Order.ShippingStreetNumber__c',
    'Order.ShippingStreetNumberExtension__c',
    'Order.ShippingIsAddressVerified__c',
    'Order.Contact__r.MobilePhone',
    'Order.Contact__r.Email',
    'Order.Account.PrimaryEmail__c',
    'Order.Account.Id',
    'Order.Account.MobilePhone__c',
    'Order.Account.BillingStreetName__c',
	'Order.Account.BillingStreetNumber__c',
	'Order.Account.BillingCity',
	'Order.Account.BillingState',
	'Order.Account.BillingPostalCode',
	'Order.Account.BillingCountry',
	'Order.Account.BillingAddressFormula__c',
	'Order.Account.BillingCityCode__c',
	'Order.Account.BillingStreetNumberExtension__c',
	'Order.Account.BillingStreetCode__c'
];
export default class hdtOrderDossierWizardSignature extends LightningElement {
    
    @api orderParentRecord;
    dataToSubmit = {};
    isDisabledSignedDate = true;
    isVisibleSignedDate = false;
    areInputsVisible = true;
    loading = false;
    currentStep = 1;
    isMailVisible = false;
    isAddrVisible = false;
    primaryContactEmail = '';
    accountAddr = '';
    ordChildBpAddr = '';
    addressOptions = [];
    choosenAddr = '';
    //EVERIS DOCUMENTALE
    @track inputParams;
    @track orderRecord;
    @track loadData=false;
    @track disabled = false;
    @api recordId;
    //FINE EVERIS DOCUMENTALE

    openAfterScriptModal = false;
    
    @api scriptMap = {};

    //START>> costanzo.lomele@webresults.it 31/08/21 - aggiornamento dati su contatto
    oldPhoneValue;
    oldEmailValue;
    //END>> costanzo.lomele@webresults.it 31/08/21 - aggiornamento dati su contatto

    get mailClasses(){
        return this.isMailVisible ? 'slds-size_1-of-2 slds-show' : 'slds-size_1-of-2 slds-hide';
    }

    get addrClasses(){
        return this.isAddrVisible ? 'slds-size_1-of-2 slds-show' : 'slds-size_1-of-2 slds-hide';
    }

    get addrFormClasses(){
        return this.isAddrVisible ? 'slds-show' : 'slds-hide';
    }

    get hiddenEdit(){
        let result = true;
        if(this.orderParentRecord.Step__c <= this.currentStep || this.orderParentRecord.Status === 'Completed'){
            result = true;
        } else if(this.orderParentRecord.Step__c > this.currentStep){
            result = false;
        }

        return result;
    }

    get disabledNext(){
        let result = false;
        if(this.orderParentRecord.Step__c != this.currentStep){
            result = true;
        } else {
            result = false;
        }
        this.disabled = result;

        return result;
    }

    get disabledInput(){
        let result = false;
        if(this.orderParentRecord.Step__c != this.currentStep){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    get isScriptBtnVisible(){
        if (this.orderRecord) {

            let hiddenEdit = true;
            if(this.orderParentRecord.Step__c <= this.currentStep || this.orderParentRecord.Status === 'Completed'){
                hiddenEdit = true;
            } else if(this.orderParentRecord.Step__c > this.currentStep){
                hiddenEdit = false;
            }

            return this.orderRecord.fields.Status.value=='In Lavorazione' && !hiddenEdit && (
                this.orderRecord.fields.SignatureMethod__c.value=='Vocal Order' || 
                this.orderRecord.fields.SignatureMethod__c.value=='OTP Remoto' || 
                this.orderRecord.fields.SignatureMethod__c.value=='OTP Coopresenza'
            )
        }
        else return false;
    }

    loadScriptMap() {
        getSignatureScript({orderParentId: this.recordId}).then(scriptMap => {
            console.log('getSignatureScript: '+JSON.stringify(scriptMap));
            this.scriptMap = scriptMap;
        });
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
        wiredOrder({ error, data }) {
            if (error) {
                let message = 'Unknown error';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    message = error.body.message;
                }
                console.log('data error ' + message);
                this.loadData = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading Case',
                        message,
                        variant: 'error',
                    }),
                );
            } else if (data) {
                console.log('data loaded');
                this.orderRecord = data;
                console.log(JSON.stringify(this.orderRecord.fields));
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
				var contractSigned = false;
                contractSigned = this.orderRecord.fields.ContractSigned__c.value;
                var contactEmail = '';
				var contactPhone = '';
                if(this.orderRecord.fields.Contact__r.value != null){
					contactEmail = this.orderRecord.fields.Contact__r.value.fields.Email.value;
					contactPhone = this.orderRecord.fields.Contact__r.value.fields.MobilePhone.value;
				}/* else if(this.orderRecord.fields.Account.value != null){
					contactEmail = this.orderRecord.fields.Account.value.fields.PrimaryEmail__c.value;
					contactPhone = this.orderRecord.fields.Account.value.fields.MobilePhone__c.value;
				} */
                var orderEmail = this.orderRecord.fields.ShippingMail__c.value;
                if(orderEmail != null && orderEmail != '')
                    email = orderEmail;
                else
                    email = contactEmail;
                var orderPhone = this.orderRecord.fields.PhoneNumber__c.value;
                
				if(orderPhone != null && orderPhone != ''){
                    phone = orderPhone;
                } else{
                    phone = contactPhone;
                }

                //START>> costanzo.lomele@webresults.it 31/08/21 - aggiornamento dati su contatto
                this.oldPhoneValue = phone;
                this.oldEmailValue = email;
                //END>> costanzo.lomele@webresults.it 31/08/21 - aggiornamento dati su contatto

                var completeAddress = '';
                var orderAddress = this.orderRecord.fields.ShippingStreetName__c.value;
                if(orderAddress != null && orderAddress != ''){
                    stato = this.orderRecord.fields.ShippingCountry__c.value;
                    provincia = this.orderRecord.fields.ShippingProvince__c.value;
                    via  = this.orderRecord.fields.ShippingStreetName__c.value;
                    cap = this.orderRecord.fields.ShippingPostalCode__c.value;
                    comune  = this.orderRecord.fields.ShippingCity__c.value;
                    civico  = this.orderRecord.fields.ShippingStreetNumber__c.value;
                    codiceComuneSAP  = this.orderRecord.fields.ShippingCityCode__c.value;
                    estensCivico = this.orderRecord.fields.ShippingStreetNumberExtension__c.value;
                    codiceViaStradarioSAP  = this.orderRecord.fields.ShippingStreetCode__c.value;
                    flagForzato  = false;
                    flagVerificato  = this.orderRecord.fields.ShippingIsAddressVerified__c.value
                    var estensioneCivico = ((estensCivico)? estensCivico:'');
                    completeAddress  = via + ' ' + civico + ' ' + estensioneCivico + ', ' + comune + ' ' + provincia + ', ' + cap + ' ' +stato;
                
                } else if(this.orderRecord.fields.Account.value != null){
                    completeAddress = this.orderRecord.fields.Account.value.fields.BillingAddressFormula__c.value;
                    stato = this.orderRecord.fields.Account.value.fields.BillingCountry.value;
                    //provincia = this.orderRecord.fields.Account.value.fields..value;
                    via  = this.orderRecord.fields.Account.value.fields.BillingStreetName__c.value;
                    cap = this.orderRecord.fields.Account.value.fields.BillingPostalCode.value;
                    comune  = this.orderRecord.fields.Account.value.fields.BillingCity.value;
                    civico  = this.orderRecord.fields.Account.value.fields.BillingStreetNumber__c.value;
                    codiceComuneSAP  = this.orderRecord.fields.Account.value.fields.BillingCityCode__c.value;
                    estensCivico = this.orderRecord.fields.Account.value.fields.BillingStreetNumberExtension__c.value;
                    codiceViaStradarioSAP  = this.orderRecord.fields.Account.value.fields.BillingStreetCode__c.value;
                    flagForzato  = false;
                    flagVerificato  = true;
                }

                var inputParams = {
					dataConfirmed:false,
					context:'Order',
					recordId:this.orderRecord.fields.Id.value,
					processType:'Vendita',
					source : this.orderRecord.fields.CreatedBy.value.fields.LoginChannel__c.value,
					phone : phone,
					email : email,
					accountId : this.orderRecord.fields.Account.value.fields.Id.value,
					quoteType : '',
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
                    sendMode:this.orderRecord.fields.DocSendingMethod__c.value,
                    signMode:this.orderRecord.fields.SignatureMethod__c.value,
                    enableEdit:this.disabledInput
                }
                this.inputParams = JSON.stringify(inputParams);
                if(contractSigned){
                    console.log('Dentro Signed');
                    this.loadData = false;
                }else{
                    console.log('Fuori Signed');
                    this.loadData = true;
                }
                console.log(this.inputParams);
            }else{
                console.log(data + ' ' + error + ' ' + this.recordId);
            }
            
        }

    connectedCallback(){
        if (this.orderParentRecord.Account.BillingAddress !== undefined) {
            this.accountAddr = this.outputFormatedAddress({
                streetName: this.orderParentRecord.Account.BillingAddress.street === undefined ? '' : this.orderParentRecord.Account.BillingAddress.street,
                place: this.orderParentRecord.Account.BillingAddress.city === undefined ? '' : this.orderParentRecord.Account.BillingAddress.city,
                postalCode: this.orderParentRecord.Account.BillingAddress.postalCode === undefined ? '' : this.orderParentRecord.Account.BillingAddress.postalCode,
                country: this.orderParentRecord.Account.BillingAddress.country === undefined ? '' : this.orderParentRecord.Account.BillingAddress.country
            });
        }
        this.handleFormInit();
        this.handleControllerInit();

        this.loadScriptMap();
    }

    outputFormatedAddress(address){

        let streetName = (address.streetName !== undefined && address.streetName !== '')  ? (address.streetName + ' ') : '';
        let streetNumber = (address.streetNumber !== undefined && address.streetNumber !== '') ? (address.streetNumber + ' ') : '';
        let streetNumberExtension = (address.streetNumberExtension !== undefined && address.streetNumberExtension !== '') ? (address.streetNumberExtension + ', ') : '';
        let place = (address.place !== undefined && address.place !== '') ? (address.place + ' ') : '';
        let province = (address.province !== undefined && address.province !== '') ? (address.province + ', ') : '';
        let postalCode = (address.postalCode !== undefined && address.postalCode !== '') ? (address.postalCode + ' ') : '';
        let country = (address.country !== undefined && address.country !== '') ? address.country : '';

        return streetName + streetNumber + streetNumberExtension + place + province + postalCode + country;
    }

    handleDataCollection(event){
        let fieldName = event.target.fieldName;
        let name = event.target.name;
        let fieldValue = event.target.value;

        console.log(name);
        console.log(fieldValue);

        if(name !== undefined){
            switch (name) {
                case 'Indirizzi':
                    this.choosenAddr = fieldValue;
                    break;
            
                default:
                    break;
            }
        }

        this.dataToSubmit[fieldName] = fieldValue;

        if (fieldName === 'ContractSigned__c') {
            this.isVisibleSignedDate = !this.isVisibleSignedDate;
            this.areInputsVisible = !this.areInputsVisible;
            if(fieldValue)
                this.loadData = false;
            else
                this.loadData = true;
        }

        if (fieldName === 'DocSendingMethod__c') {
            this.isMailVisible = (fieldValue === 'Mail');
            this.isAddrVisible = (fieldValue === 'Posta');
        }

        if (fieldName === 'SignatureMethod__c'){
            this.isMailVisible = (this.template.querySelector("[data-id='DocSendingMethod__c']").value === 'Mail');
            this.isAddrVisible = (this.template.querySelector("[data-id='DocSendingMethod__c']").value === 'Posta');
        }

    }
    handleConfirmData(event){
        this.loading = true;
        console.log('dati confermati ' + event.detail);
        this.confirmData = event.detail;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        this.dataToSubmit['Id'] = this.recordId;
        var resultWrapper = JSON.parse(event.detail);
        if(resultWrapper.dataConfirmed){
            var estensioneCivico = ((resultWrapper.addressWrapper.EstensCivico)? resultWrapper.addressWrapper.EstensCivico:'');
            var address = resultWrapper.addressWrapper.Via + ' ' + resultWrapper.addressWrapper.Civico + ' ' + estensioneCivico + ', ' + resultWrapper.addressWrapper.Comune + ' ' + resultWrapper.addressWrapper.Provincia + ', ' + resultWrapper.addressWrapper.CAP + ' ' +resultWrapper.addressWrapper.Stato;
            console.log('indirizzo completo ' +address);
            fields[PhoneNumber.fieldApiName] = resultWrapper.phone;
            this.dataToSubmit['PhoneNumber__c'] = resultWrapper.phone;
            fields[ShippingMail.fieldApiName] = resultWrapper.email;
            this.dataToSubmit['ShippingMail__c'] = resultWrapper.email;
            //fields[ADDRESS_FIELD.fieldApiName] = address;
            fields[SignatureMethod.fieldApiName] = resultWrapper.signMode;
            this.dataToSubmit['SignatureMethod__c'] = resultWrapper.signMode;
            fields[DocSendingMethod.fieldApiName] = resultWrapper.sendMode;
            this.dataToSubmit['DocSendingMethod__c'] = resultWrapper.sendMode;
            fields[ShippingPostalCode.fieldApiName] = resultWrapper.addressWrapper.CAP;
            this.dataToSubmit['ShippingPostalCode__c'] = resultWrapper.addressWrapper.CAP;
            fields[ShippingStreetNumber.fieldApiName] = resultWrapper.addressWrapper.Civico;
            this.dataToSubmit['ShippingStreetNumber__c'] = resultWrapper.addressWrapper.Civico;
            fields[ShippingCityCode.fieldApiName] = resultWrapper.addressWrapper.CodiceComuneSAP;
            this.dataToSubmit['ShippingCityCode__c'] = resultWrapper.addressWrapper.CodiceComuneSAP;
            fields[ShippingStreetCode.fieldApiName] = resultWrapper.addressWrapper.CodiceViaStradarioSAP;
            this.dataToSubmit['ShippingStreetCode__c'] = resultWrapper.addressWrapper.CodiceViaStradarioSAP;
            fields[ShippingCity.fieldApiName] = resultWrapper.addressWrapper.Comune;
            this.dataToSubmit['ShippingCity__c'] = resultWrapper.addressWrapper.Comune;
            fields[ShippingStreetNumberExtension.fieldApiName] = resultWrapper.addressWrapper.EstensCivico;
            this.dataToSubmit['ShippingStreetNumberExtension__c'] = resultWrapper.addressWrapper.EstensCivico;
            fields[ShippingIsAddressVerified.fieldApiName] = resultWrapper.addressWrapper['Flag Verificato'];
            this.dataToSubmit['ShippingIsAddressVerified__c'] = resultWrapper.addressWrapper['Flag Verificato'];
            //fields[InvoicingPlace.fieldApiName] = resultWrapper.addressWrapper.
            fields[ShippingProvince.fieldApiName] = resultWrapper.addressWrapper.Provincia;
            this.dataToSubmit['ShippingProvince__c'] = resultWrapper.addressWrapper.Provincia;
            fields[ShippingCountry.fieldApiName] = resultWrapper.addressWrapper.Stato;
            this.dataToSubmit['ShippingCountry__c'] = resultWrapper.addressWrapper.Stato;
            fields[ShippingStreetName.fieldApiName] = resultWrapper.addressWrapper.Via;
            this.dataToSubmit['ShippingStreetName__c'] = resultWrapper.addressWrapper.Via;
            const recordInput = { fields };
           
            updateRecord(recordInput)
                .then(() => {
                    //START>> costanzo.lomele@webresults.it 31/08/21 - aggiornamento dati su contatto

                    updateContactForScartoDocumentale({accountId: this.orderParentRecord.AccountId,
                                                       oldPhone: this.oldPhoneValue,
                                                       oldEmail: this.oldEmailValue,
                                                       newPhone: resultWrapper.phone,
                                                       newMail: resultWrapper.email}).then(data=>{

                    //END>> costanzo.lomele@webresults.it 31/08/21 - aggiornamento dati su contatto
                    // Display fresh data in the form
                      console.log('Record aggiornato');
                      next({orderUpdates: this.dataToSubmit}).then(data =>{
                          this.loading = false;
                          this.dispatchEvent(new CustomEvent('orderrefresh', { bubbles: true }));
                          this.dispatchEvent(new CustomEvent('tablerefresh'));
                          this.loading = false;
                          getRecordNotifyChange([{recordId: this.recordId}]);
                      }).catch(error => {
                          this.loading = false;
                          console.log((error.body.message !== undefined) ? error.body.message : error.message);
                          const toastErrorMessage = new ShowToastEvent({
                              title: 'Errore',
                              message: (error.body.message !== undefined) ? error.body.message : error.message,
                              variant: 'error',
                              mode: 'sticky'
                          });
                          this.dispatchEvent(toastErrorMessage);
                          this.loading = false;
                      });
                   });
                })
                .catch(error => {
                    console.log('Errore in aggiornamento');
                    console.log('Errore: ' + error);
                    this.loading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
        }
    }
    handleNext(){
        
        this.dataToSubmit['Id'] = this.orderParentRecord.Id;
        let returnValue = this.template.querySelector('c-hdt-document-signature-manager');
        if(returnValue){
            returnValue.checkForm();
        }else{
            this.loading = true;
            let validErrorMessage = 'Popolare il campo ';

            if(this.template.querySelector("[data-id='ContractSigned__c']").value && this.template.querySelector("[data-id='SignedDate__c']").value === null){
                validErrorMessage = validErrorMessage.concat('Data Firma, ');
            }

            if(this.template.querySelector("[data-id='SignatureMethod__c']") !== null && this.template.querySelector("[data-id='SignatureMethod__c']").value === null){
                validErrorMessage = validErrorMessage.concat('Metodo Firma, ');
            }

            if(this.template.querySelector("[data-id='DocSendingMethod__c']") !== null && this.template.querySelector("[data-id='DocSendingMethod__c']").value === null){
                validErrorMessage = validErrorMessage.concat('Modalità Invio Doc, ');
            }
            
            if(validErrorMessage === 'Popolare il campo '){
                next({orderUpdates: this.dataToSubmit}).then(data =>{
                    this.loading = false;
                    this.dispatchEvent(new CustomEvent('orderrefresh', { bubbles: true }));
                    this.dispatchEvent(new CustomEvent('tablerefresh'));
                    getRecordNotifyChange([{recordId: this.recordId}]);

                    this.loadScriptMap();
                }).catch(error => {
                    this.loading = false;
                    console.log((error.body.message !== undefined) ? error.body.message : error.message);
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: (error.body.message !== undefined) ? error.body.message : error.message,
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(toastErrorMessage);
                });
            } else {
                this.loading = false;
                console.log(validErrorMessage);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: validErrorMessage.slice(0, -2), //remove space and comma at end of error string
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            }
        }
    }

    handleEdit(){
        this.loading = true;
        edit({orderParentId:this.orderParentRecord.Id}).then(data =>{
            this.loading = false;
            this.dispatchEvent(new CustomEvent('orderrefresh', { bubbles: true }));
            this.dispatchEvent(new CustomEvent('tablerefresh'));
            this.dispatchEvent(new CustomEvent('documentalrefresh'));
            this.disabled = false;

            this.loadScriptMap();
        }).catch(error => {
            this.loading = false;
            console.log((error.body.message !== undefined) ? error.body.message : error.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: (error.body.message !== undefined) ? error.body.message : error.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleFormInit(){
        if (this.orderParentRecord.ContractSigned__c !== undefined) {
            this.isVisibleSignedDate = this.orderParentRecord.ContractSigned__c;
            this.areInputsVisible = !this.orderParentRecord.ContractSigned__c;
            if(this.orderParentRecord.ContractSigned__c){
               this.loadData = false;
            }
        }

        if (this.orderParentRecord.DocSendingMethod__c === 'Mail') {
            this.isMailVisible = true;
        }
    }
    
    handleControllerInit(){
        this.loading = true;
        controllerInit({orderParentId: this.orderParentRecord.Id, accountId: this.orderParentRecord.AccountId}).then(data =>{
            this.loading = false;
            this.primaryContactEmail = data.primaryContactEmail !== undefined ? data.primaryContactEmail : '';
            this.ordChildBpAddr = data.ordChildList[0].BillingProfile__r !== undefined ? data.ordChildList[0].BillingProfile__r : '';

            if (this.ordChildBpAddr !== '') {
                this.ordChildBpAddr = this.outputFormatedAddress({
                    streetName: data.ordChildList[0].BillingProfile__r.InvoicingStreetName__c,
                    streetNumber: data.ordChildList[0].BillingProfile__r.InvoicingStreetNumber__c,
                    streetNumberExtension: data.ordChildList[0].BillingProfile__r.InvoicingStreetNumberExtension__c,
                    place: data.ordChildList[0].BillingProfile__r.InvoicingPlace__c,
                    province: data.ordChildList[0].BillingProfile__r.InvoicingProvince__c,
                    postalCode: data.ordChildList[0].BillingProfile__r.InvoicingPostalCode__c,
                    country: data.ordChildList[0].BillingProfile__r.InvoicingCountry__c
                });
                this.addressOptions.push({label: this.ordChildBpAddr, value: this.ordChildBpAddr});
                console.log('hdtOrderDossierWizardSignature - this.accountAddr: ', this.accountAddr);
                if (this.accountAddr !== '') {
                    this.addressOptions.push({'label': this.accountAddr, 'value': this.accountAddr});
                }
                console.log('hdtOrderDossierWizardSignature - this.addressOptions: ', this.addressOptions);
            }
        }).catch(error => {
            this.loading = false;
            if (error !== undefined && error.body !== undefined) {
                console.log((error.body.message !== undefined) ? error.body.message : error.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: (error.body.message !== undefined) ? error.body.message : error.message,
                    variant: 'error'
                });
                this.dispatchEvent(toastErrorMessage);
            }
        });
    }

    handleScriptModalClose(){
        console.log('keltin close script modal');
        this.openAfterScriptModal = true;
    }

}