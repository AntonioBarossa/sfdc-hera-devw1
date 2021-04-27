import { LightningElement, api } from 'lwc';
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
	showContactList;
	showAccountList;
	noContactFound;
	

	connectedCallback() {
		init({recordId: this.recordId})
		.then(result => {
			var res = JSON.parse(result);
			this.contactId = res.contactId;
			this.accountId = res.accountId;
			this.contacts = res.contacts;
			this.accounts = res.accounts;

			this.showContactList = !this.contactId && this.contacts;
			this.noContactFound = !this.contactId && !this.contacts;
			this.showAccountList = !this.contactId && !this.accountId && this.accounts;
		})
		.catch(error => {
			// WIP
		});
	}

	handleKeyUp(event) {
		const isEnterKey = (event.keyCode === 13);
		if (isEnterKey) {
			console.log('### inside 1');
			getContacts({queryString: evt.target.value})
			.then((result) => {
				console.log('### inside 2');
				this.contacts = result;
				if(this.contacts.length == 0) {
					this.noContactFound = true;
				}
			})
			.catch(error => {
				// WIP
			});
		}
	}

	onSelectdElement(event) {
		event.target.key 
	}
}