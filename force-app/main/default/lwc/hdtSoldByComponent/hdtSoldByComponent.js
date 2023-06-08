import { LightningElement,api,track } from 'lwc';

export default class HdtSoldByComponent extends LightningElement {

    @api saleId;
    @api channel;
    searchInputValue = null;
    disabledNextAgency;
    showEmptyMessage;
    completeListcolumns = [
        { label: 'Nome Agenzia', fieldName: 'AgencyName__c', type: 'text' },
        { label: 'Codice Agenzia', fieldName: 'AgencyCode__c', type: 'text' },

    ];
    completeList;
    totalPages = 0;
    currentPage = 0;
    currentPageTwo = 0;
    @track originalData = [];
    @track pages = [];
    @track showpageOne = true;
    @track showpageTwo = false;
    loading = false;
    @track disabledBack = true;
    @track disabledNext = false;
    selectedFromCompleteList = {};
    @track completeListAgent;
    @track agentListForFilter = [];
    submitButtonStatus = true;

    connectedCallback() {
        this.handleAgencySelection();
    }

    handleAgencySelection() {

        this.disabledNextAgency = true;
        this.showEmptyMessage = false;

        getChannelAgency({ Channel: this.channel }).then(data => {

            this.completeList = [...data];

            console.log('completeListcompleteList: ', (this.completeList));
            this.originalData = this.completeList;

            if (this.completeList.length > 0) {
                console.log('handleAgencySelection: ', JSON.stringify(this.completeList));

                this.createTable(this.completeList);
            } else {
                this.showEmptyMessage = true;                
            }
        }).catch(error => {
            console.log('Error: ', JSON.stringify(error));
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

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
    }

    handleSearchInputKeyChange(event) {
        this.searchInputValue = event.target.value;
        if (this.searchInputValue.length > 3) {
            this.submitButtonStatus = false;
        } else {
            this.submitButtonStatus = true;

        }
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

    

    getSelectedFromCompleteList(event) {
        let selectedRows = event.detail.selectedRows;
        this.selectedFromCompleteList = (selectedRows[0] !== undefined) ? selectedRows[0] : {};
        this.disabledNextAgency = false;

        console.log('getSelectedFromCompleteList: ', this.selectedFromCompleteList);
    }

    handleBackPage(event) {
        this.showpageOne = true;
        this.showpageTwo = false;
        this.handleAgencySelection();
        this.disabledNextAgency = false;
        this.disabledBack = true;
        this.disabledSave = true;
    }

    handleNextPage(event) {
        this.showpageOne = false;
        this.showpageTwo = true;
        this.handleAdditionalFilter();
        this.disabledNextAgency = true;
        this.disabledBack = false;
        this.showPaginationButtons2 = true;
    }

    handleAdditionalFilter() {
        this.showEmptyMessage = false;

        console.log("this.selectedFromCompleteList.AgencyName__c", this.selectedFromCompleteList.AgencyName__c);

        getAgents({AgencyName:this.selectedFromCompleteList.AgencyName__c, Channel:this.channel}).then(data => {

            this.completeListAgent = [...data];

            console.log('getAgents completeListcompleteList: ', (this.completeListAgent));

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
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });

    }


    createTable2(data) {
        let i, j, temporary, chunk = 6;
        this.pages2 = [];
        for (i = 0, j = data.length; i < j; i += chunk) {
            temporary = data.slice(i, i + chunk);
            this.pages2.push(temporary);
        }
        this.totalPages2 = this.pages2.length;
        this.reLoadTable2();
    }

    reLoadTable2() {
        console.log('tableData='+JSON.stringify(this.tableDataAgent));
        this.tableDataAgent = this.pages2[this.currentPageTwo];
    }

    handleSave() {
        this.showpageOne = true;
        this.showpagetwo = false;

        if (Object.keys(this.selectedFromCompleteList).length != 0) {

            let saleUpdateAgent = { 
                Id: this.saleRecord.Id,
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

            this.updateSaleRecord(saleUpdateAgent);
            this.currentPage = 0;
            this.currentPageTwo = 0; // reset page
            this.template.querySelector("[data-id='Agency__c']").value = this.selectedFromCompleteList.AgencyName__c;
            this.template.querySelector("[data-id='CommercialId']").value = this.selectedFromCompleteListAgent.AgentCode__c;
            this.template.querySelector("[data-id='VendorFirstName__c']").value = this.selectedFromCompleteListAgent.AgentFirstName__c;
            this.template.querySelector("[data-id='VendorLastName__c']").value = this.selectedFromCompleteListAgent.AgentLastName__c;

        }
    }

    updateSaleRecord(saleData) {
        this.loading = true;
        updateSale({ sale: saleData }).then(data => {
            this.loading = false;
            this.dispatchEvent(new CustomEvent('saleupdate'));
        }).catch(error => {
            this.loading = false;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }
}