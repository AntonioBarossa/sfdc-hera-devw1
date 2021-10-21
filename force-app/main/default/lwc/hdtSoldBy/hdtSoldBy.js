import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLeadInfo from '@salesforce/apex/HDT_LC_SoldBy.getLeadInfo';
import updateLead from '@salesforce/apex/HDT_LC_SoldBy.updateLead';
import getChannelAgency from '@salesforce/apex/HDT_LC_SoldBy.getChannelAgency';
import getAgents from '@salesforce/apex/HDT_LC_SoldBy.getAgents';
import handleAutomaticAgentAssign from '@salesforce/apex/HDT_LC_SoldBy.handleAutomaticAgentAssign';

export default class HdtSoldBy extends LightningElement {
    @api recordId;
    openModal = false;
    showEmptyMessage = false;
    @track tableData = [];
    @track tableDataAgent = [];
    completeListcolumnsAgent = [];
    disabledBack = true;
    disabledSave = true;
    @track recordInfo;
    loading = false;
    disabledAgency = true;
    disabledNextAgency = false;
    channelSelection = '';
    @track completeList = [];
    @track originalData = [];
    totalPages = 0;
    totalPages2 = 0;
    @track pages = [];
    @track pages2 = [];
    currentPage = 0;
    currentPage2 = 0;
    hiddenFilterAgent = true;
    @track hiddenAgency = false;
    @track additionalData=[];
    @track agentListForFilter = [];
    selectedFromCompleteList = {};
    @track showpage1 = true;
    @track showpage2 = false;

    closeModal() {
        this.showpage1 = true;
        this.showpage2 = false;        
        this.openModal = false;
        this.disabledNextAgency = true;
    }

    handleAgencySelection() {
        this.disabledNextAgency = true;
        this.showEmptyMessage = false;
        let channel = this.template.querySelector('[data-name="Channel__c"]').value;
       
        this.completeListcolumns = [
            { label: 'Nome Agenzia', fieldName: 'AgencyName__c', type: 'text' },
            { label: 'Codice Agenzia', fieldName: 'AgencyCode__c', type: 'text' },

        ];

        this.loading = true;
        getChannelAgency({channel: channel }).then(data => {
            this.loading = false;
            this.openModal = true;


            this.completeList = [...data];

            console.log('completeListcompleteList: ', (this.completeList));
            this.originalData = this.completeList;

            if (this.completeList.length > 0) {
                console.log('handleAgencySelection: ', JSON.stringify(this.completeList));
                this.createTable(this.completeList);
            } else {
                this.showEmptyMessage = false;
            }
        }).catch(error => {
            console.log('Error: ', JSON.stringify(error));
            this.showErrorMessage('Errore recupero lista agenzia');
        });

    }

    //Pagination start
    createTable(data) {
        let i, j, temporary, chunk = 6;
        this.pages = [];
        for (i = 0, j = data.length; i < j; i += chunk) {
            temporary = data.slice(i, i + chunk);
            this.pages.push(temporary);
        }
        this.totalPages = this.pages.length;
        this.reLoadTable();
    }

    reLoadTable() {
        this.tableData = this.pages[this.currentPage];
        console.log('tableData='+JSON.stringify(this.tableData));

    }


    createTable2(data) {
        let i, j, temporary, chunk = 6;
        this.pages = [];
        for (i = 0, j = data.length; i < j; i += chunk) {
            temporary = data.slice(i, i + chunk);
            this.pages.push(temporary);
        }
        this.totalPages = this.pages.length;
        this.reLoadTable2();
    }

    reLoadTable2() {
        console.log('tableData='+JSON.stringify(this.tableDataAgent));
        this.tableDataAgent = this.pages[this.currentPage2];

    }

    get showPaginationButtons() {
        return this.totalPages > 1;
    }

    get getCurrentPage() {
        if (this.totalPages === 0) {
            return 0;
        } else {
            return this.currentPage + 1;
        }
    }

    get showPaginationButtons2() {
        return this.totalPages2 > 1;
    }

    get getCurrentPage2() {
        if (this.totalPages2 === 0) {
            return 0;
        } else {
            return this.currentPage2 + 1;
        }
    }

    nextPage2() {
        if (this.currentPage2 < this.totalPages2 - 1) {
            this.currentPage2++;
        }
        this.reLoadTable2();
    }

    previousPage2() {
        if (this.currentPage2 > 0) {
            this.currentPage2--;
        }
        this.reLoadTable2();
    }

    nextPage() {
        if (this.currentPage < this.totalPages - 1) {
            this.currentPage++;
        }
        this.reLoadTable();
    }
    
    previousPage() {
        if (this.currentPage > 0) {
            this.reLoadTable();
            this.currentPage--;
        }
        this.reLoadTable();
    }

    searchAgencyName(event) {
        let val = event.target.value;
        let self = this;
        let data;
        setTimeout(function () {
            data = JSON.parse(JSON.stringify(self.originalData));
            if (val.trim() !== '') {
                data = data.filter(row => {
                    let found = false;
                    let rowValues=[];
                    Object.entries(row).forEach(([key, value]) => {
                        if(key != 'Id'){
                            rowValues.push(value);
                        }
                    });
                    rowValues.forEach(v => {
                        if (v !== undefined && typeof(v)== "string" && v!='Id' && null != v.toLowerCase() && (v.toLowerCase().search(val.toLowerCase()) !== -1)) {
                            found = true;
                        }
                    });
                    if (found) return row;
                })
                
            }
            self.createTable(data); // redesign table
            self.currentPage = 0; // reset page
        }, 1000);
    }

    handleSearchInputKeyChange(event) {
        this.searchInputValue = event.target.value;
        if (this.searchInputValue.length > 3) {
            this.submitButtonStatus = false;
        } else {
            this.submitButtonStatus = true;

        }
    }

    handleAdditionalFilter() {
        this.openModal = true;
        this.showEmptyMessage = false;
        let channel = this.template.querySelector('[data-name="Channel__c"]').value;

        this.completeListcolumnsAgent = [
            { label: 'Nome Agente', fieldName: 'AgentFirstName__c', type: 'text' },
            { label: 'Cognome Agente', fieldName: 'AgentLastName__c', type: 'text' },
            { label: 'Codice Agente', fieldName: 'AgentCode__c', type: 'text' },
            { label: 'Area Manager', fieldName: 'AreaManager__c', type: 'text' },

        ];

        getAgents({agencyName:this.selectedFromCompleteList.AgencyName__c, channel:channel}).then(data => {
            

            this.completeListAgent = [...data];

            console.log('getAgents completeListcompleteList: ', (this.completeListAgent));
            //this.additionalData = this.completeListAgent;

            this.completeListAgent.forEach(item => {
                this.agentListForFilter.push({
                    AgentFirstName__c : item.AgentFirstName__c,
                    AgentLastName__c : item.AgentLastName__c,
                    AgentCode__c : item.AgentCode__c
                });

            });

            if (this.completeListAgent.length > 0) {
                console.log('getAgents: ', JSON.stringify(this.completeListAgent));

                this.currentPage2 = 0;
                this.createTable2(this.completeListAgent);
                this.disabledNextAgency =true;
            } else {
                this.showEmptyMessage = false;
            }

        }).catch(error => {
            console.log('Error: ', JSON.stringify(error));
            this.showErrorMessage('Errore recupero tabela');
        });
    }

    getSelectedFromCompleteList(event) {
        let selectedRows = event.detail.selectedRows;
        this.selectedFromCompleteList = (selectedRows[0] !== undefined) ? selectedRows[0] : {};
        this.disabledNextAgency = false;

        console.log('getSelectedFromCompleteList: ', this.selectedFromCompleteList);
    }

    getSelectedFromCompleteListAgent(event) {
        let selectedRows = event.detail.selectedRows;
        this.selectedFromCompleteListAgent = (selectedRows[0] !== undefined) ? selectedRows[0] : {};

        console.log('getSelectedFromCompleteListAgent: '+ JSON.stringify(this.selectedFromCompleteListAgent));
        this.disabledSave = false;
    }

    handleBackPage(event) {
        this.showpage1 = true;
        this.showpage2 = false;
        this.handleAgencySelection();
        this.disabledNextAgency = false;
        this.disabledBack = true;
        this.disabledSave = true;
    }

    handleNextPage(event) {
        this.showpage1 = false;
        this.showpage2 = true;
        this.handleAdditionalFilter();
        this.disabledNextAgency = true;
        this.disabledBack = false;
    }

    handleSave() {
        this.showpage1 = true;
        this.showpage2 = false;

        if (Object.keys(this.selectedFromCompleteList).length != 0) {

            let leadUpdateAgent = { 
                Id: this.recordId,
                Channel__c: this.channelSelection,
                Agency__c: this.selectedFromCompleteList.AgencyName__c,
                AgencyCode__c: this.selectedFromCompleteList.AgencyCode__c,
                VendorLastName__c:this.selectedFromCompleteListAgent.AgentLastName__c,
                VendorFirstName__c:this.selectedFromCompleteListAgent.AgentFirstName__c,
                CommercialId__c:this.selectedFromCompleteListAgent.AgentCode__c,
                UpperChannelAgency__c:this.selectedFromCompleteListAgent.UpperChannelAgency__c,
                LowerChannelAgency__c:this.selectedFromCompleteListAgent.LowerChannelAgency__c,
                IsMonitoring__c:this.selectedFromCompleteListAgent.IsMonitoring__c,
                AreaManager__c: this.selectedFromCompleteListAgent.AreaManager__c
            };

            this.updateLeadRecord(leadUpdateAgent);
            this.currentPage = 0;
            this.currentPage2 = 0; // reset page
            this.openModal = false;
        }

    }

    updateLeadRecord(leadUpdateAgent){
        this.loading = true;
        updateLead ({lead: leadUpdateAgent}).then(data =>{
            this.loading = false;
            this.showSuccessMessage('Venduto Da calcolato con successo');
        }).catch(error => {
            this.loaded = false;
            console.log(error);
            this.showErrorMessage('Errore aggiornamento');
        });
    }

    showErrorMessage(errorMessage){
        const toastErrorMessage = new ShowToastEvent({
            title: 'Errore',
            message: errorMessage,
            variant: 'error'
        });
        this.dispatchEvent(toastErrorMessage);
    }

    showSuccessMessage(successMessage){
        const toastErrorMessage = new ShowToastEvent({
            title: 'Successo',
            message: successMessage,
            variant: 'success'
        });
        this.dispatchEvent(toastErrorMessage);
        this.openModal = false;
        this.dispatchEvent(new CustomEvent('endaction'));
    }

    automaticCalculation(channel){
        this.loading = true;
        handleAutomaticAgentAssign ({channel:channel,leadId:this.recordId}).then(data =>{
            this.loading = false;
            this.showSuccessMessage('Venduto Da calcolato con successo');
        }).catch(error => {
            this.loaded = false;
            console.log(error);
            this.showErrorMessage('Errore di calcolo su canale ' + channel);
        });
    }

    async connectedCallback(){
        try {
            this.loading = true;
            this.recordInfo = await getLeadInfo({ id: this.recordId });
            console.log('hdtSoldBy mounted: ' + JSON.stringify(this.recordInfo));
        } catch (error) {
            console.log('Error: ', JSON.stringify(error));
            this.showErrorMessage('Errore nel recupero del record');
        }

        this.loading = false;

        if (this.recordInfo.CreatedBy.LoginChannel__c == 'Sportello') {
            console.log('keltin enter here');
            this.automaticCalculation('Sportello');
        }
        else if (this.recordInfo.CreatedBy.LoginChannel__c == 'Telefono Outbound' || this.recordInfo.CreatedBy.LoginChannel__c == 'Teleselling') {
            this.automaticCalculation('Teleselling Outbound');
        }
        else if (this.recordInfo.CreatedBy.LoginChannel__c == 'Telefono Inbound' || this.recordInfo.CreatedBy.LoginChannel__c == 'Teleselling') {
            this.automaticCalculation('Teleselling Inbound');
        }
    }

    handleChannelSelection(event){
        this.channelSelection = event.target.value;
        this.disabledAgency = false;
    }
}