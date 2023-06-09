import { LightningElement,api,track } from 'lwc';
import updateSale from '@salesforce/apex/HDT_LC_GeneralInfo.updateSale';
import getAgents from '@salesforce/apex/HDT_LC_GeneralInfo.getAgents';
import getChannelAgency from '@salesforce/apex/HDT_LC_GeneralInfo.getChannelAgency';
import getChannel from '@salesforce/apex/HDT_LC_SoldByController.getSaleChannel';
import getSaleChannel from '@salesforce/apex/HDT_LC_SoldByController.getSaleChannel';

const CONST_CHUNK = 6;
export default class HdtSoldByComponent extends LightningElement {
    

    @api saleid;
    channel;
    searchInputValue = null;
    disabledNextAgency;
    showEmptyMessage;
    @track message;
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
    loading = true;
    @track disabledBack = true;
    @track disabledNext = false;
    selectedFromCompleteList = {};
    selectedFromCompleteListAgent = {};
    @track completeListAgent;
    @track agentListForFilter = [];
    submitButtonStatus = true;
    @track disabledSave = true;
    @track tableDataAgent = [];
    @track pagesTwo = [];
    connectedCallback() {
        console.log('@@@@ea vendita ' + this.saleid);
        if (this.saleid){
            getSaleChannel({saleId : this.saleid}).then( data => {
                this.channel = data;
                console.log('@ea channel ' + this.channel);
                if (this.channel){
                    this.handleAgencySelection();
                }
            }).catch(error => {
                console.error(error);
            });
            
        }
    }

    get showPaginationButtonsTwo() {
        return this.totalPagesTwo > 1;
    }

    get getCurrentPageTwo() {
        if (this.totalPagesTwo === 0) {
            return 0;
        } else {
            return this.currentPageTwo + 1;
        }
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
                this.message = 'Non ci sono agienzie attive in corso';    
            }
            this.loading = false;
        }).catch(error => {
            this.launchEvent('errorcomponent',error.body.message);
        });
    }

    createTable(data) {
        let i, j, temporary, chunk = CONST_CHUNK;
        this.pages = [];
        for (i = 0, j = data.length; i < j; i += chunk) {
            temporary = data.slice(i, i + chunk);
            this.pages.push(temporary);
        }
        this.totalPages = this.pages.length;
        console.log('@ea total page ' + this.totalPages);
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

    getSelectedFromCompleteListAgent(event) {
        let selectedRows = event.detail.selectedRows;
        this.selectedFromCompleteListAgent = (selectedRows[0] !== undefined) ? selectedRows[0] : {};

        console.log('getSelectedFromCompleteListAgent: '+ JSON.stringify(this.selectedFromCompleteListAgent));
        this.disabledSave = false;
    }

    getSelectedFromCompleteList(event) {
        let selectedRows = event.detail.selectedRows;
        this.selectedFromCompleteList = (selectedRows[0] !== undefined) ? selectedRows[0] : {};
        this.disabledNextAgency = false;

        console.log('getSelectedFromCompleteList: ', this.selectedFromCompleteList);
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

    searchAgentTable(event) {
        let val = event.target.value;
        let self = this;
        let data;
        setTimeout(function () {
            data = JSON.parse(JSON.stringify(self.completeListAgent));
            if (val.trim() !== '') {
                data = data.filter(row => {
                    let found = false;
                    Object.values(row).forEach(v => {
                        if (v !== undefined && typeof(v)== "string" && null != v.toLowerCase() && (v.toLowerCase().search(val.toLowerCase()) !== -1)) {
                            found = true;
                        }
                    });
                    if (found) return row;
                })
            }
            self.createTableTwo(data); // redesign table
            self.currentPageTwo = 0; // reset page
        }, 1000);
    }

    nextPageTwo() {
        if (this.currentPageTwo < this.totalPagesTwo - 1) {
            this.currentPageTwo++;
        }
        this.reLoadTableTwo();
    }

    previousPageTwo() {
        if (this.currentPageTwo > 0) {
            this.currentPageTwo--;
        }
        this.reLoadTableTwo();
    }

    get showPaginationButtons() {
        console.log('@ea total page ' + this.totalPages);
        return this.totalPages > 1;
    }

    get getCurrentPage() {
        if (this.totalPages === 0) {
            return 0;
        } else {
            return this.currentPage + 1;
        }
    }

    handleBackPage(event) {
        this.showpageOne = true;
        this.showpageTwo = false;
        this.handleAgencySelection();
        this.disabledNextAgency = true;
        this.disabledBack = true;
        this.disabledSave = true;
    }

    handleNextPage(event) {
        this.showpageOne = false;
        this.showpageTwo = true;
        this.handleAdditionalFilter();
        this.disabledNextAgency = true;
        this.disabledBack = false;
        this.showPaginationButtonsTwo = true;
    }

    handleAdditionalFilter() {
        this.showEmptyMessage = false;

        console.log("this.selectedFromCompleteList.AgencyName__c", this.selectedFromCompleteList.AgencyName__c);

        getAgents({AgencyName:this.selectedFromCompleteList.AgencyName__c, Channel:this.channel}).then(data => {
            console.log('@ea data ' + JSON.stringify(data));
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
                this.currentPageTwo = 0;
                this.createTableTwo(this.completeListAgent);
                this.disabledNextAgency =true;
            } else {
                this.showEmptyMessage = true;
                this.message = "Non ci sono agenti";
            }
        }).catch(error => {
            this.launchEvent('errorcomponent',error.body.message);
        });

    }


    createTableTwo(data) {
        let i, j, temporary, chunk = CONST_CHUNK;
        this.pagesTwo = [];
        for (i = 0, j = data.length; i < j; i += chunk) {
            temporary = data.slice(i, i + chunk);
            this.pagesTwo.push(temporary);
        }
        this.totalPagesTwo = this.pagesTwo.length;
        this.reLoadTableTwo();
    }

    reLoadTableTwo() {
        console.log('tableData='+JSON.stringify(this.tableDataAgent));
        this.tableDataAgent = this.pagesTwo[this.currentPageTwo];
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

        }
    }

    updateSaleRecord(saleData) {
        this.loading = true;
        updateSale({ sale: saleData }).then(data => {
            this.launchEvent('selectevent',JSON.stringify(saleData));
        }).catch(error => {
            this.launchEvent('errorcomponent',error.body.message);
        });
    }

    launchEvent(event,message){
        this.dispatchEvent(new CustomEvent(event,{detail : message}));
    }
}