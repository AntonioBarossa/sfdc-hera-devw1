import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import init from '@salesforce/apex/HDT_LC_AccountSelectorController.init';
import getContacts from '@salesforce/apex/HDT_LC_AccountSelectorController.getContacts';
import handleAccount from '@salesforce/apex/HDT_LC_AccountSelectorController.handleAccount';
import updateActivity from '@salesforce/apex/HDT_LC_AccountSelectorController.updateActivity';

export default class HdtAccountSelector extends LightningElement {
	@api recordId;
	contactId;
	accountId;
	contacts;
	accounts;
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
						this.dispatchEvent(new ShowToastEvent({
							variant: 'error',
							title: 'Errore',
							message: 'Si è verificato un errore. Ricaricare la pagina e riprovare.',
						}));
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
					getRecordNotifyChange([{recordId: this.recordId}]);
					this.dispatchEvent(new ShowToastEvent({
						variant: 'success',
						title: 'Account Trovato',
						message: 'L\'account è stato automaticamente associato all\'activity corrente.',
					}));
				}
			})
			.catch(error => {
				// WIP
				console.log('error ' + error);
				this.dispatchEvent(new ShowToastEvent({
					variant: 'error',
					title: 'Errore',
					message: 'Si è verificato un errore. Ricaricare la pagina e riprovare.',
				}));
			});
		} else if(this.showAccountSearchPanel) {
			this.accountId = event.currentTarget.dataset.id;
			updateActivity({activityId: this.recordId, contactId: this.contactId, accountId: this.accountId})
			.then(result => {
				getRecordNotifyChange([{recordId: this.recordId}]);
				this.dispatchEvent(new ShowToastEvent({
					variant: 'success',
					title: 'Successo',
					message: 'L\'activity è stata aggiornata.',
				}));
			})
			.catch(ERROR => {
				// WIP
				console.log('error ' + error);
				this.dispatchEvent(new ShowToastEvent({
					variant: 'error',
					title: 'Errore',
					message: 'Si è verificato un errore. Ricaricare la pagina e riprovare.',
				}));
			});
		}
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