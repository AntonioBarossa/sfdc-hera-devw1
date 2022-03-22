import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import init from '@salesforce/apex/HDT_LC_AccountSelectorController.init';
import search from '@salesforce/apex/HDT_LC_AccountSelectorController.search';
import handleLead from '@salesforce/apex/HDT_LC_AccountSelectorController.handleLead';
import handleAccount from '@salesforce/apex/HDT_LC_AccountSelectorController.handleAccountSerialized';
import updateRecord from '@salesforce/apex/HDT_LC_AccountSelectorController.updateRecord';
import reset from '@salesforce/apex/HDT_LC_AccountSelectorController.reset';

export default class HdtAccountSelector extends NavigationMixin(LightningElement) {
	@api recordId;
	isCall;
	leadId;
	contactId;
	accountId;
	leads;
	contacts;
	accounts;
	changesCommitted;
	showSpinner;
	navigateOnSelectAccount = true;
	get resetButtonDisabled() {
		return !this.contactId && !this.accountId && !this.leadId;
	}
	get showResetMessage() {
		return this.contactId && this.accountId || this.leadId;
	}
	get showContactSearchPanel() {
		return !this.contactId && !this.leadId && !this.accounts;
	}
	get leadsFound() {
		return this.leads;
	}
	get accountsFound() {
		return this.accounts;
	}
	get contactsFound() {
		return this.contacts;
	}
	get searchResults() {
		return (this.leads && this.leads.length > 0) || (this.accounts && this.accounts.length > 0) || (this.contacts && this.contacts.length > 0);
	}
	get showAccountSearchPanel() {
		return !this.accountId && this.accounts;
	}

	connectedCallback() {
		this.showSpinner = true;
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
				this.template.querySelector(`[data-id="search_bar_anagrafica"]`).value = res.preFilter;
			}
			this.refreshPage();
		})
		.catch(error => {
			// WIP
			console.error(error);
			this.showGenericErrorToast();
		})
		.then(() => {
			this.showSpinner = false;
		});
	}

	handleKeyUp(event) {
		const isEnterKey = (event.keyCode === 13);
		if (isEnterKey) {
			if(this.showContactSearchPanel) {
				this.showSpinner = true;
				var queryString = event.target.value;
				if(queryString) {
					search({queryString: queryString, recordId: this.recordId})
					.then(result => {
						var resObj = JSON.parse(result);
						console.log('### ' + result);
						this.navigateOnSelectAccount = false;
						this.leads = resObj.leads;
						this.contacts = resObj.contacts;
						this.accounts = resObj.accounts;
					})
					.catch(error => {
						// WIP
						console.error(error);
						this.showGenericErrorToast();
					})
					.then(() => {
						this.showSpinner = false;
					});
				}
			}
		}
	}

	handleClick(event) {
		this.showSpinner = true;
		var selectedRecordId = event.currentTarget.dataset.id;
		switch(event.currentTarget.dataset.sobjtype) {
			case 'Account' :
				this.accountId = event.currentTarget.dataset.id;
				if(!this.contactId) {
					this.contactId = this.contacts[0] ? this.contacts[0].Id : null;
				}
				updateRecord({recordId: this.recordId, contactId: this.contactId, accountId: this.accountId})
				.then(result => {
					this.changesCommitted = true;
					this.refreshPage();
					this.showToast('success', 'Successo', 'Il record è stato aggiornato.');

					if(this.navigateOnSelectAccount) {
						this.navigateToRecordPage(this.accountId, 'Account');
					}
				})
				.catch(error => {
					// WIP
					console.error(error);
					this.showGenericErrorToast();
				});
			break;
			case 'Contact' :
				this.contactId = selectedRecordId;
				handleAccount({contactId: this.contactId, recordId: this.recordId})
				.then(result => {
					var resultObj = JSON.parse(result);
					if(resultObj.length == 1) {
						this.accountId = resultObj[0].Id;
						this.changesCommitted = true;
						this.refreshPage();
						this.showToast('success', 'Account Trovato', 'L\'account è stato automaticamente associato al record corrente.');

						if(this.navigateOnSelectAccount) {
							this.navigateToRecordPage(this.accountId, 'Account');
						}
					}
					this.accounts = resultObj;
				})
				.catch(error => {
					// WIP
					console.error(error);
					this.showGenericErrorToast();
				});
			break;
			case 'Lead' :
				this.leadId = selectedRecordId;
				handleLead({leadId: this.leadId, recordId: this.recordId})
				.then(result => {
					this.changesCommitted = true;
					this.refreshPage();
					this.showToast('success', 'Successo', 'Il record è stato aggiornato.');
				})
				.catch(error => {
					// WIP
					console.error(error);
					this.showGenericErrorToast();
				});
			break;
		}
		this.showSpinner = false;
	}

	handleReset(event) {
		this.showSpinner = true;
		this.contactId = undefined;
		this.accountId = undefined;
		this.leadId = undefined;
		this.contacts = undefined;
		this.accounts = undefined;
		this.leads = undefined;
		if(this.changesCommitted) {
			reset({recordId: this.recordId})
			.then(result => {
				this.refreshPage();
			})
			.catch(error => {
				// WIP
				console.error(error);
			});
		}
		this.showSpinner = false;
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

	navigateToRecordPage(recordId, sobjectApiName) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: recordId,
				objectApiName: sobjectApiName,
				actionName: 'view'
			}
		});
	}
}