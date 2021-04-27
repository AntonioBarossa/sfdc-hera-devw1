import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import init from '@salesforce/apex/HDT_LC_AccountSelectorController.init';
import getContacts from '@salesforce/apex/HDT_LC_AccountSelectorController.getContacts';
import handleAccount from '@salesforce/apex/HDT_LC_AccountSelectorController.handleAccount';
import updateActivity from '@salesforce/apex/HDT_LC_AccountSelectorController.updateActivity';
import reset from '@salesforce/apex/HDT_LC_AccountSelectorController.reset';

export default class HdtAccountSelector extends LightningElement {
	@api recordId;
	contactId;
	accountId;
	contacts;
	accounts;
	changesCommitted;
	get resetButtonDisabled() {
		return !this.contactId && !this.accountId;
	}
	get showResetMessage() {
		return this.contactId && this.accountId;
	}
	get showContactSearchPanel() {
		return !this.contactId;
	}
	get contactsFound() {
		return this.contacts;
	}
	get showAccountSearchPanel() {
		return this.contactId && !this.accountId;
	}
	get accountsFound() {
		return this.accounts;
	}

	connectedCallback() {
		init({recordId: this.recordId})
		.then(result => {
			var res = JSON.parse(result);
			this.contactId = res.contactId;
			this.accountId = res.accountId;
			this.contacts = res.contacts;
			this.accounts = res.accounts;
			this.changesCommitted = this.contactId && this.accountId;
		})
		.catch(error => {
			// WIP
		});
	}

	handleKeyUp(event) {
		const isEnterKey = (event.keyCode === 13);
		if (isEnterKey) {
			if(this.showContactSearchPanel) {
				var queryString = event.target.value;
				if(queryString) {
					getContacts({queryString: queryString})
					.then(result => {
						this.contacts = result;
					})
					.catch(error => {
						// WIP
						console.log('error ' + error);
						this.showGenericErrorToast();
					});
				}
			}
		}
	}

	handleClick(event) {
		if(this.showContactSearchPanel) {
			this.contactId = event.currentTarget.dataset.id;
			handleAccount({contactId: this.contactId, activityId: this.recordId})
			.then(result => {
				this.accounts = result;
				if(result.length == 1) {
					this.accountId = this.accounts[0].Id;
					this.changesCommitted = true;
					getRecordNotifyChange([{recordId: this.recordId}]);
					this.showToast('success', 'Account Trovato', 'L\'account è stato automaticamente associato all\'activity corrente.');
				}
			})
			.catch(error => {
				// WIP
				console.log('error ' + error);
				this.showGenericErrorToast();
			});
		} else if(this.showAccountSearchPanel) {
			this.accountId = event.currentTarget.dataset.id;
			updateActivity({activityId: this.recordId, contactId: this.contactId, accountId: this.accountId})
			.then(result => {
				this.changesCommitted = true;
				getRecordNotifyChange([{recordId: this.recordId}]);
				this.showToast('success', 'Successo', 'L\'activity è stata aggiornata.');
			})
			.catch(error => {
				// WIP
				console.log('error ' + error);
				this.showGenericErrorToast();
			});
		}
	}

	handleReset(event) {
		this.contactId = undefined;
		this.accountId = undefined;
		if(this.changesCommitted) {
			reset({activityId: this.recordId})
			.then(result => {
				getRecordNotifyChange([{recordId: this.recordId}]);
			})
			.catch(error => {
				// WIP
				console.log('### ERROR: ' + error)
			});
		}
	}

	showGenericErrorToast() {
		this.showToast('error', 'Errore', 'Si è verificato un errore. Ricaricare la pagina e riprovare. Se il problema persiste contattare il supporto tecnico.');
	}
	
	showToast(variant, title, message) {
		this.dispatchEvent(new ShowToastEvent({
			variant: variant,
			title: title,
			message: message
		}));
	}

	// WIP
	handleMouseOver(event) {
		var x = event.currentTarget.dataset.id;
		this.template.querySelector(`[data-id="${x}"]`).classList.add("hovered");
	}
	
	handleMouseOut(event) {
		this.template.querySelector(`[data-id="${x}"]`).classList.remove('hovered');
	}
}