import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import init from '@salesforce/apex/HDT_LC_AccountSelectorController.init';
import getContacts from '@salesforce/apex/HDT_LC_AccountSelectorController.getContacts';
import handleAccount from '@salesforce/apex/HDT_LC_AccountSelectorController.handleAccount';
import getAccounts from '@salesforce/apex/HDT_LC_AccountSelectorController.getAccounts';
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
						// this.contactsFound = (this.contacts.length > 0);
					})
					.catch(error => {
						// WIP
						console.log('error ' + error);
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
					this.dispatchEvent(new ShowToastEvent({
						variant: 'success',
						title: 'Account Trovato',
						message: 'L\'account è stato automaticamente associato all\'activity corrente.',
					}));
				}
			})
			.catch(error => {
				// WIP
			});
		} else if(this.showAccountSearchPanel) {
			this.accountId = event.currentTarget.dataset.id;
			updateActivity({activityId: this.recordId, contactId: this.contactId, accountId: this.accountId})
			.then(result => {
				// TOAST
			})
			.catch(ERROR => {
				// WIP
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