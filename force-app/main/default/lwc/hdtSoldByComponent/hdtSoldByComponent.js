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
    completeListcolumnsAgent = [
        { label: 'Nome Agente', fieldName: 'AgentFirstName__c', type: 'text' },
        { label: 'Cognome Agente', fieldName: 'AgentLastName__c', type: 'text' },
        { label: 'Codice Agente', fieldName: 'AgentCode__c', type: 'text' },
        { label: 'Area Manager', fieldName: 'AreaManager__c', type: 'text' },
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
    @track disabledSave = true;
    @track tableDataAgent = [];
    @track tableData = [];
    @track pagesTwo = [];
    connectedCallback() {
        if (this.saleid){
            getSaleChannel({saleId : this.saleid}).then( data => {
                this.channel = data;
                console.log('@ea channel ' + this.channel);
                if (this.channel){
                    this.handleAgencySelection();
                }
            }).catch(error => {
                this.launchEvent('errorcomponent',error.body.message);
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

            this.originalData = this.completeList;

            if (this.completeList.length > 0) {  
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


    searchAgencyName(event) {
        let val = event.target.value;
        let self = this;
        let data;
        setTimeout(function () {
            data = JSON.parse(JSON.stringify(self.originalData));
            if (val.trim() !== '' && val.length >= 3) {
                data = data.filter(row => {     
                    let found = false;
                    let rowValues=[];
                    Object.values(row).forEach(v => {
                        if (v !== undefined && typeof(v)== "string" && null != v.toLowerCase() && (v.toLowerCase().search(val.toLowerCase()) !== -1)) {
                            found = true;
                        }
                    });
                    return found;
                });
            }
            self.currentPage = 0; // reset page
            self.createTable(data); // redesign table
        }, 1000);

    }

    getSelectedFromCompleteListAgent(event) {
        let selectedRows = event.detail.selectedRows;
        this.selectedFromCompleteListAgent = (selectedRows[0] !== undefined) ? selectedRows[0] : {};

        this.disabledSave = false;
    }

    getSelectedFromCompleteList(event) {
        let selectedRows = event.detail.selectedRows;
        this.selectedFromCompleteList = (selectedRows[0] !== undefined) ? selectedRows[0] : {};
        this.disabledNextAgency = false;
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
            if (val.trim() !== '' && val.length >= 3) {
                data = data.filter(row => {
                    let found = false;
                    Object.values(row).forEach(v => {
                        if (v !== undefined && typeof(v)== "string" && null != v.toLowerCase() && (v.toLowerCase().search(val.toLowerCase()) !== -1)) {
                            found = true;
                        }
                    });
                    return found;
                })
            }
            self.currentPageTwo = 0; // reset page
            self.createTableTwo(data); // redesign table
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


        getAgents({AgencyName:this.selectedFromCompleteList.AgencyName__c, Channel:this.channel}).then(data => {
            this.completeListAgent = [...data];

            this.completeListAgent.forEach(item => {
                this.agentListForFilter.push({
                    AgentFirstName__c : item.AgentFirstName__c,
                    AgentLastName__c : item.AgentLastName__c,
                    AgentCode__c : item.AgentCode__c
                });
            });

            if (this.completeListAgent.length > 0) {
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
        this.tableDataAgent = this.pagesTwo[this.currentPageTwo];
    }

    handleSave() {
        this.showpageOne = true;
        this.showpageTwo = false;
        if (Object.keys(this.selectedFromCompleteList).length != 0) {
            let saleUpdateAgent = { 
                Id: this.saleid,
                Agency__c: this.selectedFromCompleteList.AgencyName__c ? this.selectedFromCompleteList.AgencyName__c : '',
                AgencyCode__c: this.selectedFromCompleteList.AgencyCode__c ? this.selectedFromCompleteList.AgencyCode__c : '',
                VendorLastName__c:this.selectedFromCompleteListAgent.AgentLastName__c ? this.selectedFromCompleteListAgent.AgentLastName__c : '',
                VendorFirstName__c:this.selectedFromCompleteListAgent.AgentFirstName__c ? this.selectedFromCompleteListAgent.AgentFirstName__c : '',
                CommercialId__c:this.selectedFromCompleteListAgent.AgentCode__c ? this.selectedFromCompleteListAgent.AgentCode__c : '',
                UpperChannelAgency__c:this.selectedFromCompleteListAgent.UpperChannelAgency__c ? this.selectedFromCompleteListAgent.UpperChannelAgency__c : '',
                LowerChannelAgency__c:this.selectedFromCompleteListAgent.LowerChannelAgency__c ? this.selectedFromCompleteListAgent.LowerChannelAgency__c : '',
                IsMonitoring__c:this.selectedFromCompleteListAgent.IsMonitoring__c ? true : false,
                AreaManager__c: this.selectedFromCompleteListAgent.AreaManager__c ? this.selectedFromCompleteListAgent.AreaManager__c : ''
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
        this.dispatchEvent(new CustomEvent(event,{detail : {message}}));
    }
}