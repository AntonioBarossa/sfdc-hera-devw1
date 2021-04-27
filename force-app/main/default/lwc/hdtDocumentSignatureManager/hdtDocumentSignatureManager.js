import { LightningElement,track,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtDocumentSignatureManager extends NavigationMixin(LightningElement) {
    //ProcessType: Required. For Sale pass the value 'Sale', for post sales pass the value of the CaseType.c/hdtAddDocumentSelected.
    //The variable is used to calculate Modalità Firma & Modalità Spedizione Combobox Values
    @api processType;
    //ProcessType: Required. Pass the User Source (Call Center, Sportello). Used to calculate Modalità Firma & Modalità Spedizione Combobox Values
    @api source;
    //Phone: Required. Pass the Phone number
    @api phone;
    //Phone: Required. Pass the Email.
    @api email;
    //Address: Required. This variable is a complex type Name - Value. Pass all the fields that compose an Address and the Complete Address.
    @api address;
    //AccountId: Required. Pass the Id of the Account. Used to retreive all the Account Address.
    @api accountId;
    buttonStatefulState = false;
    @track disableEdit = false;
    @track emailRequired;
    @track phoneRequired;
    @track addressRequired;
    connectedCallback(){

    }

    get modalitaFirma() {
        return [
            { label: 'OTP', value: 'otp' },
            { label: 'Vocal Order', value: 'vocalOrder' },
            { label: 'Cartacea', value: 'cartacea' },
        ];
    }

    get modalitaSpedizione() {
        return [
            { label: 'Email', value: 'email' },
            { label: 'Posta cartacea', value: 'postaCartacea' },
            { label: 'Stampa Cartacea', value: 'stampaCartacea' },
        ];
    }

    checkRequired(){
        try{
            var modFirma = this.template.querySelector("lightning-combobox[data-id=modalitaFirma]").value;
            var modSpedizione = this.template.querySelector("lightning-combobox[data-id=modalitaSpedizione]").value;
            if(modFirma.localeCompare('otp')===0){
                this.emailRequired = true;
                this.phoneRequired = true;
                this.addressRequired = false;
            }else if(modSpedizione.localeCompare('stampaCartacea')===0){
                this.emailRequired = false;
                this.phoneRequired = false;
                this.addressRequired = true;
            }else if(modSpedizione.localeCompare('email')===0){
                this.phoneRequired = false;
                this.addressRequired = false;
                this.emailRequired = true;
            }else if(modSpedizione.localeCompare('postaCartacea')===0){
                this.emailRequired = false;
                this.phoneRequired = false;
                this.addressRequired = true;
            }
        }catch (error) {
            console.error(error);
        }
    }

    handleChange(event){
        this.checkRequired();
    }
    
    checkForm(){
        try{
            var modFirma = this.template.querySelector("lightning-combobox[data-id=modalitaFirma]");
            var modSpedizione = this.template.querySelector("lightning-combobox[data-id=modalitaSpedizione]");
            var telefono = this.template.querySelector("lightning-input[data-id=telefono]");      
            var email =this.template.querySelector("lightning-input[data-id=email]");      
            var address = this.template.querySelector("lightning-input[data-id=indirizzoRecapito]");
            if(!modFirma.value || !modSpedizione.value || (this.phoneRequired && !telefono.value) || (this.emailRequired && !email.value) || (this.addressRequired && !address.value))
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
            }
            //console.log(modFirma.value + modSpedizione.value + telefono.value + email.value + address.value);
        }catch (error) {
            console.error(error);
        }
        
        
       /* if(modFirma.value && modSpedizione.value && telefono.value && email.value && address.value){
            this.buttonStatefulState = !this.buttonStatefulState
            this.enableEdit = this.buttonStatefulState;
        }else{
            this.showMessage('Errore','Valorizza tutti i campi obbligatori','error');  
        }*/
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

            var base64 = "JVBERi0xLjMNCiXi48/TDQoNCjEgMCBvYmoNCjw8DQovVHlwZSAvQ2F0YWxvZw0KL091dGxpbmVzIDIgMCBSDQovUGFnZXMgMyAwIFINCj4+DQplbmRvYmoNCg0KMiAwIG9iag0KPDwNCi9UeXBlIC9PdXRsaW5lcw0KL0NvdW50IDANCj4+DQplbmRvYmoNCg0KMyAwIG9iag0KPDwNCi9UeXBlIC9QYWdlcw0KL0NvdW50IDINCi9LaWRzIFsgNCAwIFIgNiAwIFIgXSANCj4+DQplbmRvYmoNCg0KNCAwIG9iag0KPDwNCi9UeXBlIC9QYWdlDQovUGFyZW50IDMgMCBSDQovUmVzb3VyY2VzIDw8DQovRm9udCA8PA0KL0YxIDkgMCBSIA0KPj4NCi9Qcm9jU2V0IDggMCBSDQo+Pg0KL01lZGlhQm94IFswIDAgNjEyLjAwMDAgNzkyLjAwMDBdDQovQ29udGVudHMgNSAwIFINCj4+DQplbmRvYmoNCg0KNSAwIG9iag0KPDwgL0xlbmd0aCAxMDc0ID4+DQpzdHJlYW0NCjIgSg0KQlQNCjAgMCAwIHJnDQovRjEgMDAyNyBUZg0KNTcuMzc1MCA3MjIuMjgwMCBUZA0KKCBBIFNpbXBsZSBQREYgRmlsZSApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDY4OC42MDgwIFRkDQooIFRoaXMgaXMgYSBzbWFsbCBkZW1vbnN0cmF0aW9uIC5wZGYgZmlsZSAtICkgVGoNCkVUDQpCVA0KL0YxIDAwMTAgVGYNCjY5LjI1MDAgNjY0LjcwNDAgVGQNCigganVzdCBmb3IgdXNlIGluIHRoZSBWaXJ0dWFsIE1lY2hhbmljcyB0dXRvcmlhbHMuIE1vcmUgdGV4dC4gQW5kIG1vcmUgKSBUag0KRVQNCkJUDQovRjEgMDAxMCBUZg0KNjkuMjUwMCA2NTIuNzUyMCBUZA0KKCB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDYyOC44NDgwIFRkDQooIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlICkgVGoNCkVUDQpCVA0KL0YxIDAwMTAgVGYNCjY5LjI1MDAgNjE2Ljg5NjAgVGQNCiggdGV4dC4gQW5kIG1vcmUgdGV4dC4gQm9yaW5nLCB6enp6ei4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kICkgVGoNCkVUDQpCVA0KL0YxIDAwMTAgVGYNCjY5LjI1MDAgNjA0Ljk0NDAgVGQNCiggbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDU5Mi45OTIwIFRkDQooIEFuZCBtb3JlIHRleHQuIEFuZCBtb3JlIHRleHQuICkgVGoNCkVUDQpCVA0KL0YxIDAwMTAgVGYNCjY5LjI1MDAgNTY5LjA4ODAgVGQNCiggQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgKSBUag0KRVQNCkJUDQovRjEgMDAxMCBUZg0KNjkuMjUwMCA1NTcuMTM2MCBUZA0KKCB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBFdmVuIG1vcmUuIENvbnRpbnVlZCBvbiBwYWdlIDIgLi4uKSBUag0KRVQNCmVuZHN0cmVhbQ0KZW5kb2JqDQoNCjYgMCBvYmoNCjw8DQovVHlwZSAvUGFnZQ0KL1BhcmVudCAzIDAgUg0KL1Jlc291cmNlcyA8PA0KL0ZvbnQgPDwNCi9GMSA5IDAgUiANCj4+DQovUHJvY1NldCA4IDAgUg0KPj4NCi9NZWRpYUJveCBbMCAwIDYxMi4wMDAwIDc5Mi4wMDAwXQ0KL0NvbnRlbnRzIDcgMCBSDQo+Pg0KZW5kb2JqDQoNCjcgMCBvYmoNCjw8IC9MZW5ndGggNjc2ID4+DQpzdHJlYW0NCjIgSg0KQlQNCjAgMCAwIHJnDQovRjEgMDAyNyBUZg0KNTcuMzc1MCA3MjIuMjgwMCBUZA0KKCBTaW1wbGUgUERGIEZpbGUgMiApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDY4OC42MDgwIFRkDQooIC4uLmNvbnRpbnVlZCBmcm9tIHBhZ2UgMS4gWWV0IG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gKSBUag0KRVQNCkJUDQovRjEgMDAxMCBUZg0KNjkuMjUwMCA2NzYuNjU2MCBUZA0KKCBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSB0ZXh0LiBBbmQgbW9yZSApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDY2NC43MDQwIFRkDQooIHRleHQuIE9oLCBob3cgYm9yaW5nIHR5cGluZyB0aGlzIHN0dWZmLiBCdXQgbm90IGFzIGJvcmluZyBhcyB3YXRjaGluZyApIFRqDQpFVA0KQlQNCi9GMSAwMDEwIFRmDQo2OS4yNTAwIDY1Mi43NTIwIFRkDQooIHBhaW50IGRyeS4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gQW5kIG1vcmUgdGV4dC4gKSBUag0KRVQNCkJUDQovRjEgMDAxMCBUZg0KNjkuMjUwMCA2NDAuODAwMCBUZA0KKCBCb3JpbmcuICBNb3JlLCBhIGxpdHRsZSBtb3JlIHRleHQuIFRoZSBlbmQsIGFuZCBqdXN0IGFzIHdlbGwuICkgVGoNCkVUDQplbmRzdHJlYW0NCmVuZG9iag0KDQo4IDAgb2JqDQpbL1BERiAvVGV4dF0NCmVuZG9iag0KDQo5IDAgb2JqDQo8PA0KL1R5cGUgL0ZvbnQNCi9TdWJ0eXBlIC9UeXBlMQ0KL05hbWUgL0YxDQovQmFzZUZvbnQgL0hlbHZldGljYQ0KL0VuY29kaW5nIC9XaW5BbnNpRW5jb2RpbmcNCj4+DQplbmRvYmoNCg0KMTAgMCBvYmoNCjw8DQovQ3JlYXRvciAoUmF2ZSBcKGh0dHA6Ly93d3cubmV2cm9uYS5jb20vcmF2ZVwpKQ0KL1Byb2R1Y2VyIChOZXZyb25hIERlc2lnbnMpDQovQ3JlYXRpb25EYXRlIChEOjIwMDYwMzAxMDcyODI2KQ0KPj4NCmVuZG9iag0KDQp4cmVmDQowIDExDQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMTkgMDAwMDAgbg0KMDAwMDAwMDA5MyAwMDAwMCBuDQowMDAwMDAwMTQ3IDAwMDAwIG4NCjAwMDAwMDAyMjIgMDAwMDAgbg0KMDAwMDAwMDM5MCAwMDAwMCBuDQowMDAwMDAxNTIyIDAwMDAwIG4NCjAwMDAwMDE2OTAgMDAwMDAgbg0KMDAwMDAwMjQyMyAwMDAwMCBuDQowMDAwMDAyNDU2IDAwMDAwIG4NCjAwMDAwMDI1NzQgMDAwMDAgbg0KDQp0cmFpbGVyDQo8PA0KL1NpemUgMTENCi9Sb290IDEgMCBSDQovSW5mbyAxMCAwIFINCj4+DQoNCnN0YXJ0eHJlZg0KMjcxNA0KJSVFT0YNCg==\n"; 
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

        }catch(err){
            console.log(err.message);
        }
    }
}