import { LightningElement, track, api } from 'lwc';
import offerConfiguratorHelper from './hdtOfferConfiguratorHelper';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';
import saveNewOfferConfigured from '@salesforce/apex/HDT_LC_OfferConfiguratorController.saveNewOfferConfigured';

export default class HdtOfferConfigurator extends NavigationMixin(LightningElement) {
    @track dataRows = [];
    @track selection;
    @api productid;
    @track spinnerObj = {
        spinner: false,
        spincss: ''
    };

    field1 = 'AAAAA';
    field2 = 'AAAAA';
    field3 = 'EE - Libero ven. Fuori rete con Lim';
    helpTxt1 = 'This field1 indicate that...';
    helpTxt2 = 'This field2 indicate that...';
    helpTxt3 = 'This field3 indicate that...';
    error;

    

    // eslint-disable-next-line @lwc/lwc/no-async-await
    async connectedCallback() {
        this.spinnerObj.spinner = true;
        this.spinnerObj.spincss = 'loadingdata slds-text-heading_small';

        const data = await offerConfiguratorHelper();

        /*var i;
        for(i=0; i<data.length; i++){
            console.log(' save row [' + (i+1) +']: ' +
                data[i].amount.label + '; Id: ' + data[i].amount.id + '; checkUser: ' + data[i].checkUser
            );
        }*/

        setTimeout(() => {
            this.dataRows = data;
            this.spinnerObj.spinner = false;
        }, 3000);

    }

    handleSetvaluetoparent(event){
        let element = this.dataRows.find(ele  => ele.id === event.detail.rowId);

        switch (event.detail.fieldName) {
            case 'amount':
                console.log('# Amount -> ' + element.amount.label);
                element.amount.label = event.detail.label;
                element.amount.id = event.detail.recId;
                break;
            case 'grInfo':
                console.log('# grInfo -> ' + element.grInfo.label);
                element.grInfo.label = event.detail.label;
                element.grInfo.id = event.detail.recId;
                break;
            case 'price':
                console.log('# price -> ' + element.price.label);
                element.price.label = event.detail.label;
                element.price.id = event.detail.recId;
                break;
            case 'discount':
                console.log('# discount -> ' + element.discount.label);
                element.discount.label = event.detail.label;
                element.discount.id = event.detail.recId;
                break;
            case 'value':
                console.log('# value -> ' + element.value.label);
                element.value.label = event.detail.label;
                element.value.id = event.detail.recId;
                break;
            case 'stringValue':
                console.log('# stringValue -> ' + element.stringValue.label);
                element.stringValue.label = event.detail.label;
                element.stringValue.id = event.detail.recId;    
        }

        //check row value and get error in case
        //put error to row
        let e = this.template.querySelector('[data-id="' + event.detail.rowId + '"]');
        //
        var rowChecked = this.checkRowValues(e);
        console.log('@ ' + rowChecked.success + ' - ' + rowChecked.message);
        if(rowChecked.success){
            //success

        } else {
            //error
            e.classList.add('alertRow');
        }

    }

    checkRowValues(rowElement) {
        console.log('# checkRowValues #');
        var retError = {
            success: true,
            message: 'nothing to declare'
        };
        return retError;
    }

    handleChange(event){
        console.log('# onchange checkbox #');
        var rowId = event.currentTarget.getAttribute('data-id');
        var checked = event.currentTarget.name;
        let element = this.dataRows.find(ele  => ele.id === rowId);
        element.checkUser = !checked;
    }

    goBackToRecord(){
        console.log('# goBackToRecord -> ' + this.productid);

        var i;
        for(i=0; i<this.dataRows.length; i++){
            this.dataRows[i].amount.label = '';
            this.dataRows[i].amount.id = '';
            this.dataRows[i].grInfo.label = '';
            this.dataRows[i].grInfo.id = '';
            this.dataRows[i].price.label = '';
            this.dataRows[i].price.id = '';
            this.dataRows[i].discount.label = '';
            this.dataRows[i].discount.id = '';
            this.dataRows[i].value.label = '';
            this.dataRows[i].value.id = '';
            this.dataRows[i].stringValue.label = '';
            this.dataRows[i].stringValue.id = '';
        }

        console.log('# gotothepage #');

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.productid,
                objectApiName: 'Product2',
                actionName: 'view'
            }
        });

    }

    saveAction(event){
        console.log('# Save offert configured #');
        /*var i;
        for(i=0; i<this.dataRows.length; i++){
            console.log(' save row [' + (i+1) +']: ' +
                this.dataRows[i].amount.label + '; Id: ' + this.dataRows[i].amount.id + '; checkUser: ' + this.dataRows[i].checkUser
            );
        }*/
        this.spinnerObj.spinner = true;
        this.spinnerObj.spincss = 'savingdata slds-text-heading_small';

        //this.sendToApex();

        setTimeout(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Successo!',
                    message: 'Offerta salvata correttamente',
                    variant: 'success'
                }),
            );
            this.spinnerObj.spinner = false;
            this.goBackToRecord();
            
        }, 3000);

    }

    sendToApex(){
        console.log('# sendToApex #');
        saveNewOfferConfigured({offerJson: JSON.stringify(this.dataRows)})
        .then(result => {
            console.log('# save success #');
            console.log('# resp -> ' + result.success);

            var toastObj = {
                title: '',
                message: '',
                variant: ''
            };

            if(result.success){
                toastObj.title = 'Successo';
                toastObj.message = result.message;
                toastObj.variant = 'success';
            } else {
                toastObj.title = 'Attenzione';
                toastObj.message = result.message;
                toastObj.variant = 'warning';                    
            }

            this.error = undefined;

            setTimeout(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: toastObj.title,
                        message: toastObj.message,
                        variant: toastObj.variant
                    }),
                );
            
            }, 5000);

        })
        .catch(error => {
            console.log('# save error #');
            console.log('# resp -> ' + result.message);

            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while saving Record',
                    message: error.message,
                    variant: 'error',
                }),
            );
            setTimeout(() => {
                
            }, 5000);
        });
    }

}