import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import init from '@salesforce/apex/HDT_LC_AccountSelectorController.init';
import getContacts from '@salesforce/apex/HDT_LC_AccountSelectorController.getContacts';
import getLeads from '@salesforce/apex/HDT_LC_AccountSelectorController.getLeads';
import getLeadsAndContacts from '@salesforce/apex/HDT_LC_AccountSelectorController.getLeadsAndContacts';
import handleLead from '@salesforce/apex/HDT_LC_AccountSelectorController.handleLead';
import handleAccount from '@salesforce/apex/HDT_LC_AccountSelectorController.handleAccount';
import updateActivity from '@salesforce/apex/HDT_LC_AccountSelectorController.updateActivity';
import reset from '@salesforce/apex/HDT_LC_AccountSelectorController.reset';

export default class HdtAccountSelector extends LightningElement {
	@api recordId;
	isCall;
	leadId;
	contactId;
	accountId;
	leads;
	contacts;
	accounts;
	changesCommitted;
	get resetButtonDisabled() {
		return !this.contactId && !this.accountId && !this.leadId;
	}
	get showResetMessage() {
		return this.contactId && this.accountId || this.leadId;
	}
	get showContactSearchPanel() {
		return !this.contactId && !this.leadId;
	}
	get leadsFound() {
		return this.leads;
	}
	get contactsFound() {
		return this.contacts;
	}
	get showAccountSearchPanel() {
		return this.contactId && !this.accountId && !this.leadId;
	}
	get accountsFound() {
		return this.accounts;
	}

	connectedCallback() {
		init({recordId: this.recordId})
		.then(result => {
			var res = JSON.parse(result);
			this.isCall = res.isCall;
			this.leadId = res.leadId;
			this.contactId = res.contactId;
			this.accountId = res.accountId;
			this.leads = res.leads;
			this.contacts = res.contacts;
			this.accounts = res.accounts;
			this.changesCommitted = this.leadId || this.contactId || this.accountId;
			if(res.preFilter) {
				console.log(this.template.querySelector('search_bar_anagrafica'));
				console.log(this.template.querySelector(`[data-id="search_bar_anagrafica"]`));
				console.log(this.template.querySelector(`[data-id="search_bar_anagrafica"]`).value = res.preFilter);
			}
			console.log(this.leads);
			console.log(this.contacts);
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
					console.log('calling');
					getLeadsAndContacts({queryString: queryString})
					.then(result => {
						this.leads = result.leads;
						this.contacts = result.contacts;
					})
					.catch(error => {
						// WIP
						console.error(error);
						this.showGenericErrorToast();
					});
				}
			}
		}
	}

	handleClick(event) {
		console.log('### event ');
		console.log('### event ' + event.currentTarget.dataset.id);
		var selectedRecordId = event.currentTarget.dataset.id;
		if(this.showContactSearchPanel) {
			switch(event.currentTarget.dataset.sobjtype) {
				case 'Contact' :
					this.contactId = selectedRecordId;
					handleAccount({contactId: this.contactId, activityId: this.recordId})
					.then(result => {
						if(result.length == 1) {
							this.accountId = result[0].Id;
							this.changesCommitted = true;
							this.refreshPage();
							this.showToast('success', 'Account Trovato', 'L\'account è stato automaticamente associato all\'activity corrente.');
						}
						this.accounts = result;
					})
					.catch(error => {
						// WIP
						console.error(error);
						this.showGenericErrorToast();
					});
					break;
				case 'Lead' :
					this.leadId = selectedRecordId;
					handleLead({leadId: this.leadId, activityId: this.recordId})
					.then(result => {
						this.changesCommitted = true;
						this.refreshPage();
						this.showToast('success', 'Successo', 'L\'activity è stata aggiornata.');
					})
					.catch(error => {
						// WIP
						console.error(error);
						this.showGenericErrorToast();
					});
					break;
					default:
						console.log('### default');
			}
		} else if(this.showAccountSearchPanel) {
			this.accountId = event.currentTarget.dataset.id;
			updateActivity({activityId: this.recordId, contactId: this.contactId, accountId: this.accountId})
			.then(result => {
				this.changesCommitted = true;
				this.refreshPage();
				this.showToast('success', 'Successo', 'L\'activity è stata aggiornata.');
			})
			.catch(error => {
				// WIP
				console.error(error);
				this.showGenericErrorToast();
			});
		}
	}

	handleReset(event) {
		this.contactId = undefined;
		this.accountId = undefined;
		this.leadId = undefined;
		this.contacts = undefined;
		this.accounts = undefined;
		this.leads = undefined;
		if(this.changesCommitted) {
			reset({activityId: this.recordId})
			.then(result => {
				this.refreshPage();
			})
			.catch(error => {
				// WIP
				console.error(error);
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

	refreshPage() {
		getRecordNotifyChange([{recordId: this.recordId}]);
	}
}