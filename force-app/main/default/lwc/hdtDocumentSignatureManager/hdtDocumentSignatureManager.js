import { LightningElement,track,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import previewDocumentFile from '@salesforce/apex/HDT_LC_DocumentSignatureManager.previewDocumentFile';
import getSignSendMode from '@salesforce/apex/HDT_LC_DocumentSignatureManager.getSignSendMode';

export default class HdtDocumentSignatureManager extends NavigationMixin(LightningElement) {
    //ProcessType: Required. For Sale pass the subtype, for post sales pass the value of the CaseType
    //The variable is used to calculate Modalità Firma & Modalità Spedizione Combobox Values
    @track processType;
    //Source: Required. Pass the User Source (Call Center, Sportello). Used to calculate Modalità Firma & Modalità Spedizione Combobox Values
    @track source;
    //Phone: Required. Pass the Phone number
    @track phone;
    //Phone: Required. Pass the Email.
    @track email;
    //Address: Required. This variable is a complex type Name - Value. Pass all the fields that compose an Address and the Complete Address.
    @track address;
    //AccountId: Required. Pass the Id of the Account. Used to retreive all the Account Address.
    @track accountId;
    @track documents;
    @api params;

    buttonStatefulState = false;
    @track disableEdit = false;
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
    
    connectedCallback(){
        try{
            if(this.params){
                this.returnWrapper = JSON.parse(this.params);
                var inputWrapper = JSON.parse(this.params);
                this.context = inputWrapper.context;
                this.recordId = inputWrapper.recordId;
                this.processType = inputWrapper.processType;
                this.source = inputWrapper.source;
                this.phone = inputWrapper.phone;
                this.email = inputWrapper.email;
                this.accountId = inputWrapper.accountId;
                this.documents = inputWrapper.documents;
                this.quoteType = inputWrapper.quoteType;//var addressWrapper = JSON.parse(inputWrapper.addressWrapper);
                this.address = inputWrapper.addressWrapper.completeAddress;
                this.signMode = inputWrapper.signMode;
                this.sendMode = inputWrapper.sendMethod;
                if(this.context.localeCompare('Order') === 0 || this.quoteType.localeCompare('Analitico') === 0){
                    this.enablePreview = false;
                }else{
                    this.enablePreview = true;
                }
                this.addressWrapper = inputWrapper.addressWrapper;
                getSignSendMode({
                    processType: this.processType,
                    source: this.source,
                }).then(result => {
                    var resultJSON = JSON.parse(result);
                    console.log(resultJSON);
                    var signMode = [];
                    var sendMode = [];
                    var signSendMode;
                    var signSendModeList = [];
                    resultJSON.forEach((element) => {
                        signMode.push(element.signMode);
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
                    this.signSendMap = signSendModeList; 
                    this.modalitaFirma = signMode;
                    if(this.sendMode != null && this.sendMode != ''){
                        this.modalitaInvio = signSendModeList.find(function(post, index) {
                            if(post.signMode == this.sendMode)
                                return true;
                        });
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

    checkRequired(){
        try{
            var modFirma = this.template.querySelector("lightning-combobox[data-id=modalitaFirma]").value;
            var modSpedizione = this.template.querySelector("lightning-combobox[data-id=modalitaSpedizione]").value;
            console.log('mod sped' + modSpedizione);
            if(modFirma.localeCompare('OTP Coopresenza')===0 || modFirma.localeCompare('OTP Remoto')===0){
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
            var temp = this.signSendMap.find(function(post, index) {
                if(post.signMode == event.detail.value)
                    return true;
            });
            console.log(JSON.stringify(temp));
            this.modalitaInvio = temp.sendMode;
            console.log('mod invio ' + this.modalitaInvio);
            this.phoneRequired = false;
            this.addressRequired = false;
            this.emailRequired = false;
            this.checkRequired();
        }catch(error){
            console.error(error);
        }
        
    }
    
    checkForm(){
        try{
            var modFirma = this.template.querySelector("lightning-combobox[data-id=modalitaFirma]");
            var modSpedizione = this.template.querySelector("lightning-combobox[data-id=modalitaSpedizione]");
            var telefono = this.template.querySelector("lightning-input[data-id=telefono]");      
            var email =this.template.querySelector("lightning-input[data-id=email]");      
            var address = this.template.querySelector("lightning-input[data-id=indirizzoRecapito]");
            /*if(!modFirma.value || !modSpedizione.value || (this.phoneRequired && !telefono.value) || (this.emailRequired && !email.value) || (this.addressRequired && !address.value))
            {
                this.showMessage('Errore','Valorizza tutti i campi obbligatori','error'); 
            }else{
                this.buttonStatefulState = !this.buttonStatefulState
                this.enableEdit = this.buttonStatefulState;
                var wrapperResult = {
                    signMethod:modFirma,
                    sendMethod:modSpedizione,
                    phone:telefono,
                    email:email,
                    address:{
                        completeAddress:address
                    }
                }
                this.dispatchEvent(new CustomEvent('confirmdata'), { detail: wrapperResult });
            }*/
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
                        this.returnWrapper.signMode = modFirma.value;
                        this.returnWrapper.sendMethod = modSpedizione.value;
                        this.returnWrapper.phone = telefono.value;
                        this.returnWrapper.email = email.value;
                        this.returnWrapper.addressWrapper.completeAddress = address.value;
                        // JSON.stringify(this.returnWrapper)
                        this.dispatchEvent(new CustomEvent('confirmdata', { detail: JSON.stringify(this.returnWrapper)}));

                    }
                }
        }catch (error) {
            console.error(error);
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

    handleButtonStatefulClick() {
        
        this.checkForm();

    }

    handlePreview(){
        try{
            var formParams = {
                sendMode : this.template.querySelector("lightning-combobox[data-id=modalitaFirma]").value,
                telefono : this.template.querySelector("lightning-input[data-id=telefono]").value,      
                email : this.template.querySelector("lightning-input[data-id=email]").value,      
                address : this.template.querySelector("lightning-input[data-id=indirizzoRecapito]").value
            };
            previewDocumentFile({
                recordId: this.recordId,
                context: this.context,
                formParams: JSON.stringify(formParams)
            }).then(result => {
                //var base64 = "JVBERi0xLjMNCiXi48/TDQoNCjEgMCBvYmoNCjw8DQovVHlwZSAvQ2F0YWxvZw0KL091dGxpbmVzIDIgMCBSDQovUGFnZXMgMyAwIFINCj4+DQplbmRvYmoNCg0KMiAwIG9iag0KPDwNCi9UeXBlIC9PdXRsaW5lcw0KL0NvdW50IDANCj4+DQplbmRvYmoNCg0KMyAwIG9iag0KPDwNCi9UeXBlIC9QYWdlcw0KL0NvdW50IDINCi9LaWRzIFsgNCAwIFIgNiAwIFIgXSANCj4+DQplbmRvYmoNCg0KNCAwIG9iag0KPDwNCi9UeXBlIC9QYWdlDQovUGFyZW50IDMgMCBSDQovUmVzb3VyY2VzIDw8DQovRm9udCA8PA0KL0YxIDkgMCBSIA0KPj4NCi9Qcm9jU2V0IDggMCBSDQo+Pg0KL01lZGlhQm94IFswIDAgNjEyLjAwMDAgNzkyLjAwMDBdDQovQ29udGVudHMgNSAwIFINCj4+DQplbmRvYmoNCg0KNSAwIG9iag0KPDwgL0xlbmd0aCAxMDc0ID4+DQpzdHJlYW0NCjIgSg0KQlQNCjAgMCAwIHJnDQovRjEgMDAyNyBUZg0KNTcuMzc1MCA3MjIuMjgwMCBUZA0KKCBBIFNpbXBsZSBQREYgRmlsZSApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDY4OC42MDgwIFRkDQooIFRoaXMgaXMgYSBzbWFsbCBkZW1vbnN0cmF0aW9uIC5wZGYgZmlsZSAtICkgVGoNCkVUDQpCVA0KL0YxIDAwMTAgVGYNCjY5LjI1MDAgNjY0LjcwNDAgVGQNCigganVzdCBmb3IgdXNlIGluIHRoZSBWaXJ0dWFsIE1lY2hhbmljcyB0dXRvcmlhbHMuIE1vcmUgdGV4dC4gQW5kIG1vcmUgKSBUag0KRVQNCkJUDQovRjEgMDAxMCBUZg0KNjkuMjUwMCA2NTIuNzUyMCBUZA0KKCB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDYyOC44NDgwIFRkDQooIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlICkgVGoNCkVUDQpCVA0KL0YxIDAwMTAgVGYNCjY5LjI1MDAgNjE2Ljg5NjAgVGQNCiggdGV4dC4gQW5kIG1vcmUgdGV4dC4gQm9yaW5nLCB6enp6ei4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kICkgVGoNCkVUDQpCVA0KL0YxIDAwMTAgVGYNCjY5LjI1MDAgNjA0Ljk0NDAgVGQNCiggbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDU5Mi45OTIwIFRkDQooIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlIHRleHQuICkgVGoNCkVUDQpCVA0KL0YxIDAwMTAgVGYNCjY5LjI1MDAgNTY5LjA4ODAgVGQNCiggQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgKSBUag0KRVQNCkJUDQovRjEgMDAxMCBUZg0KNjkuMjUwMCA1NTcuMTM2MCBUZA0KKCB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBFdmVuIG1vcmUuIENvbnRpbnVlZCBvbiBwYWdlIDIgLi4uKSBUag0KRVQNCmVuZHN0cmVhbQ0KZW5kb2JqDQoNCjYgMCBvYmoNCjw8DQovVHlwZSAvUGFnZQ0KL1BhcmVudCAzIDAgUg0KL1Jlc291cmNlcyA8PA0KL0ZvbnQgPDwNCi9GMSA5IDAgUiANCj4+DQovUHJvY1NldCA4IDAgUg0KPj4NCi9NZWRpYUJveCBbMCAwIDYxMi4wMDAwIDc5Mi4wMDAwXQ0KL0NvbnRlbnRzIDcgMCBSDQo+Pg0KZW5kb2JqDQoNCjcgMCBvYmoNCjw8IC9MZW5ndGggNjc2ID4+DQpzdHJlYW0NCjIgSg0KQlQNCjAgMCAwIHJnDQovRjEgMDAyNyBUZg0KNTcuMzc1MCA3MjIuMjgwMCBUZA0KKCBTaW1wbGUgUERGIEZpbGUgMiApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDY4OC42MDgwIFRkDQooIC4uLmNvbnRpbnVlZCBmcm9tIHBhZ2UgMS4gWWV0IG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gKSBUag0KRVQNCkJUDQovRjEgMDAxMCBUZg0KNjkuMjUwMCA2NzYuNjU2MCBUZA0KKCBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDY2NC43MDQwIFRkDQooIHRleHQuIE9oLCBob3cgYm9yaW5nIHR5cGluZyB0aGlzIHN0dWZmLiBCdXQgbm90IGFzIGJvcmluZyBhcyB3YXRjaGluZyApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDY1Mi43NTIwIFRkDQooIHBhaW50IGRyeS4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gKSBUag0KRVQNCkJUDQovRjEgMDAxMCBUZg0KNjkuMjUwMCA2NDAuODAwMCBUZA0KKCBCb3JpbmcuICBNb3JlLCBhIGxpdHRsZSBtb3JlIHRleHQuIFRoZSBlbmQsIGFuZCBqdXN0IGFzIHdlbGwuICkgVGoNCkVUDQplbmRzdHJlYW0NCmVuZG9iag0KDQo4IDAgb2JqDQpbL1BERiAvVGV4dF0NCmVuZG9iag0KDQo5IDAgb2JqDQo8PA0KL1R5cGUgL0ZvbnQNCi9TdWJ0eXBlIC9UeXBlMQ0KL05hbWUgL0YxDQovQmFzZUZvbnQgL0hlbHZldGljYQ0KL0VuY29kaW5nIC9XaW5BbnNpRW5jb2RpbmcNCj4+DQplbmRvYmoNCg0KMTAgMCBvYmoNCjw8DQovQ3JlYXRvciAoUmF2ZSBcKGh0dHA6Ly93d3cubmV2cm9uYS5jb20vcmF2ZVwpKQ0KL1Byb2R1Y2VyIChOZXZyb25hIERlc2lnbnMpDQovQ3JlYXRpb25EYXRlIChEOjIwMDYwMzAxMDcyODI2KQ0KPj4NCmVuZG9iag0KDQp4cmVmDQowIDExDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMTkgMDAwMDAgbg0KMDAwMDAwMDA5MyAwMDAwMCBuDQowMDAwMDAwMTQ3IDAwMDAwIG4NCjAwMDAwMDAyMjIgMDAwMDAgbg0KMDAwMDAwMDM5MCAwMDAwMCBuDQowMDAwMDAxNTIyIDAwMDAwIG4NCjAwMDAwMDE2OTAgMDAwMDAgbg0KMDAwMDAwMjQyMyAwMDAwMCBuDQowMDAwMDAyNDU2IDAwMDAwIG4NCjAwMDAwMDI1NzQgMDAwMDAgbg0KDQp0cmFpbGVyDQo8PA0KL1NpemUgMTENCi9Sb290IDEgMCBSDQovSW5mbyAxMCAwIFINCj4+DQoNCnN0YXJ0eHJlZg0KMjcxNA0KJSVFT0YNCg==\n"; 
                var base64 = result;
                var sliceSize = 512;
                base64 = base64.replace(/^[^,]+,/, '');
                base64 = base64.replace(/\s/g, '');
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

                this[NavigationMixin.Navigate](
                    {
                        type: 'standard__webPage',
                        attributes: {
                            url: blobURL
                        }
                    }
                );
                this.dispatchEvent(new CustomEvent('previewexecuted'));
            })
            .catch(error => {
                console.error(error);
            });
        }catch(error){
            console.error();
        }
    }
}