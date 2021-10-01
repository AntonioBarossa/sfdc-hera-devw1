import { LightningElement, track } from 'lwc';

export default class HdtSoldBy extends LightningElement {
    openModal = false;
    showEmptyMessage = false;
    @track tableData = [];
    @track tableDataAgent = [];
    completeListcolumnsAgent = [];
    disabledBack = true;
    disabledSave = true;

    closeModal() {
        this.showpage1 = true;
        this.showpage2 = false;        
        this.openModal = false;
        this.disabledNextAgency = true;
    }

    handleAgencySelection() {

        this.openModal = true;
        this.disabledNextAgency = true;
        this.showEmptyMessage = false;
        let Channel = this.template.querySelector('[data-name="Channel__c"]').value;
        console.log("Channel", Channel)
       
        this.completeListcolumns = [
            { label: 'Nome Agenzia', fieldName: 'AgencyName__c', type: 'text' },
            { label: 'Codice Agenzia', fieldName: 'AgencyCode__c', type: 'text' },

        ];

        getChannelAgency({ Channel: this.ChannelSelection }).then(data => {

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
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
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
        let Channel = this.template.querySelector('[data-name="Channel__c"]').value;

        this.completeListcolumnsAgent = [
            { label: 'Nome Agente', fieldName: 'AgentFirstName__c', type: 'text' },
            { label: 'Cognome Agente', fieldName: 'AgentLastName__c', type: 'text' },
            { label: 'Codice Agente', fieldName: 'AgentCode__c', type: 'text' },
            { label: 'Area Manager', fieldName: 'AreaManager__c', type: 'text' },

        ];

        console.log("Channel", Channel);
        console.log("this.selectedFromCompleteList.AgencyName__c", this.selectedFromCompleteList.AgencyName__c);


        getAgents({AgencyName:this.selectedFromCompleteList.AgencyName__c, Channel:Channel}).then(data => {
            

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
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
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
            this.currentPage2 = 0; // reset page
            //this.toggle();
            this.openModal = false;
            //this.template.querySelector('[data-name="Agency__c"]').setAttribute('value', this.selectedFromCompleteList.AgencyName__c);
            this.template.querySelector("[data-id='Agency__c']").value = this.selectedFromCompleteList.AgencyName__c;
            this.template.querySelector("[data-id='CommercialId']").value = this.selectedFromCompleteListAgent.AgentCode__c;
            this.template.querySelector("[data-id='VendorFirstName__c']").value = this.selectedFromCompleteListAgent.AgentFirstName__c;
            this.template.querySelector("[data-id='VendorLastName__c']").value = this.selectedFromCompleteListAgent.AgentLastName__c;

        }

    }

    connectedCallback(){
        console.log('hdtSoldBy mounted');
    }
}