import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';
import assignAccountToUser from "@salesforce/apex/HDT_LC_AccountReAssignToMe.assignAccountToUser";

export default class HdtAssignAccountToMe extends LightningElement {
    @api recordId;
    showSpinner;
    
    connectedCallback() {
        this.showSpinner = true;
        this.showSpinner= false;
    }

    handleChangeAccountOwner(){
        this.showSpinner = true;
        assignAccountToUser({accId: this.recordId}).then(data =>{
            if(data == 'OK'){
                this.showToast('success', 'Success', 'Cliente modificato con Successo.');
            }
            else{
                this.showToast('error', 'Errore', data);
            }
            this.closeModal();
        });
    }

	showToast(variant, title, message) {
		this.dispatchEvent(new ShowToastEvent({
			variant: variant,
			title: title,
			message: message
		}));
	}

    closeModal() {
        this.showSpinner= false;
        this.dispatchEvent(new CloseActionScreenEvent());
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 1000);
    }
}