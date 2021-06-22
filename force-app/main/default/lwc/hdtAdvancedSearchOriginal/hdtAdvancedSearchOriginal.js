import { LightningElement/*, api, track, wire*/ } from 'lwc';
/*//import {labels} from 'c/labels';
//import {error} from 'c/notificationSvc';
//import querySupply from '@salesforce/apex/AdvancedSearchCnt.querySupply';
import queryPoint from '@salesforce/apex/HDT_LC_AdvancedSearchOriginal.queryServicePoint';
//import searchSupply from '@salesforce/apex/AdvancedSearchCnt.searchSupply';
import searchPoint from '@salesforce/apex/HDT_LC_AdvancedSearchOriginal.searchServicePoint';

*/
export default class hdtAdvancedSearchOriginal extends LightningElement {
    /*label = labels;

    @track loading = false;

    @api expectedResult = 'Supply__c';
    @api multiSelection = false;
    @api accountId
    @api supplyStatus
    @api companyDivision
    @api disabled = false;
    
    @api
    supplyColumns  = [
        {key:'RecordType.Name', label:'Type'},
        {key:'Name', label:'Supply'},
        {key:'ServicePoint__r.Name', label:'Service Point'},
        {key:'Status__c', label:'Status'},
        {key:'ContractAccount__r.Name', label:'Contract Account'},
        {key:'Contract__r.ContractNumber', label:'Contract'},
        {key:'CompanyDivision__r.Name', label:'Company'},
        {key:'Product__r.Name', label:'Product'}
    ];

    @api
    pointColumns  = [
        {key:'RecordType.Name', label:'Type'},
        {key:'CurrentSupply__r.Name', label:'Supply'},
        {key:'Name', label:'Service Point'},
        {key:'CurrentSupply__r.Status__c', label:'Current Supply Status'},
        {key:'CurrentSupply__r.ContractAccount__r.Name', label:'Contract Account'},
        {key:'CurrentSupply__r.Contract__r.ContractNumber', label:'Contract'},
        {key:'CurrentSupply__r.CompanyDivision__r.Name', label:'Company'},
        {key:'CurrentSupply__r.Product__r.Name', label:'Product'}
    ];
    
    @track columns = [];
    queryResult
    groupBy = 'ServiceSite__c';
    @track results;
    @track showModal = false;
    
    selectedItems = [];
    
    get groupByOptions() {
        return [
            { label: 'Service Site', value: (this.expectedResult === 'Supply__c' ? 'ServiceSite__c' : 'CurrentSupply__r.ServiceSite__c'), checked: true},
            { label: 'Contract Account', value:  (this.expectedResult === 'Supply__c' ? 'ContractAccount__c' : 'CurrentSupply__r.ContractAccount__c') },
            { label: 'Contract', value:  (this.expectedResult === 'Supply__c' ? 'Contract__c' : 'CurrentSupply__r.Contract__c') },
        ];
    }
    
    connectedCallback() {
        this.columns = this.supplyColumns;
        if(this.expectedResult === 'ServicePoint__c') {
            this.columns = this.pointColumns;
        }
    }

    handleGroupByChange(evt) {
        this.loading = true;
        
        let newCol;
        let fromPoint = 'CurrentSupply__r.';
        
        this.groupBy = evt.detail.value;

        let searchCol;
        if(this.groupBy.endsWith('Contract__c')) {
            searchCol = 'Contract__r.ContractNumber';
        } else if(this.groupBy.endsWith('ContractAccount__c')) {
            searchCol = 'ContractAccount__r.Name';
        } else {
            searchCol = 'ServiceSite__r.SiteAddress__c';
        }

        if(this.expectedResult === 'ServicePoint__c'){
            searchCol = fromPoint + searchCol;
        }

        this.groupElements(this.queryResult, this.groupBy, this.expectedResult).then(
            (result) =>{
                this.results = result;
                if(this.template.querySelector('c-grouped-table')){
                    this.template.querySelector('c-grouped-table').resetPage();
                }
                let index = this.columns.findIndex((col)=> col.key === searchCol);
                let previousGroupBy = this.groupBy;
                if(previousGroupBy.endsWith('Contract__c')) {
                    newCol = {key:'Contract__r.ContractNumber', label:'Contract'};
                } else if(previousGroupBy.endsWith('ContractAccount__c')) {
                    newCol = {key:'ContractAccount__r.Name', label:'Contract Account'};
                } else {
                    newCol = {key:'ServiceSite__r.SiteAddress__c', label:'Service Site'};
                }
                if(this.expectedResult === 'ServicePoint__c'){
                    newCol.key = fromPoint + newCol.key;
                }

                this.columns[index] = newCol;  
                this.loading = false;
                this.showModal = true;
            }
        );
    }

    @api
    resetBox() {
        let inputCmp = this.template.querySelector('[data-id="searchBox"]');
        inputCmp.value = '';
        this.results = null;
        this.selectedItems = [];
        this.removeError();
    }

    closeModal() {
        this.resetBox();
        this.showModal = false;
    }

    handleChange(event) {
        event.target.classList.remove('slds-has-error');
    }

    removeError = () => {
        let areValid = true;
        let requireFields = Array.from(this.template.querySelectorAll('lightning-input'));
        requireFields.forEach((inputRequiredCmp) => {
            let valueInput = inputRequiredCmp.value;
            if (valueInput == null || valueInput.trim() === '') {
                inputRequiredCmp.classList.remove('slds-has-error');
                areValid = false;
            }
        });
        return areValid;
    };

    @track value
    @track spinner
    @api
    search() {
        let searchBox = this.template.querySelector('[data-id="searchBox"]')
        this.value = searchBox.value;
        this.spinner = true;
        
        if(this.expectedResult === 'Supply__c'){
            querySupply({
                searchText : this.value,
                accountId : this.accountId,
                companyDivision : this.companyDivision,
                supplyStatus : this.supplyStatus
            }).then((response) => {
                this.queryResult = response;
                this.groupElements(response, this.groupBy, this.expectedResult).then(
                    (result) =>{
                        this.results = result;
                        if(this.template.querySelector('c-grouped-table')){
                            this.template.querySelector('c-grouped-table').resetPage();
                        }
                        this.spinner = false;
                        this.showModal = true;
                    }
                )
            }).catch((errorMsg) => {
                this.spinner = false;
                error(this, errorMsg.body.message);
            });
        } else {
            queryPoint({
                searchText : this.value,
                accountId : this.accountId,
                companyDivision : this.companyDivision,
                supplyStatus : this.supplyStatus
            }).then((response) => {
                this.queryResult = response;
                this.groupElements(response, this.groupBy, this.expectedResult).then(
                    (result) =>{
                        this.results = result;
                        if(this.template.querySelector('c-grouped-table')){
                            this.template.querySelector('c-grouped-table').resetPage();
                        }
                        this.spinner = false;
                        this.showModal = true;
                    }
                )
            }).catch((errorMsg) => {
                this.spinner = false;
                error(this, errorMsg.body.message);
            });
        }
    }

    advancedSearch() {
        this.loading = true;
        let searchBox = this.template.querySelector('[data-id="advancedSearchBox"]')
        let value = searchBox.value;
        
        if (!value || value.trim() === '') {
            searchBox.classList.add('slds-has-error');
            this.loading = false;
            error(this, this.label.requiredFields);
            return;
        }

        if(this.expectedResult === 'Supply__c'){
            searchSupply({
                searchText : value,
                accountId : this.accountId,
                companyDivision : this.companyDivision,
                supplyStatus : this.supplyStatus
            }).then((response) => {
                this.queryResult = response;
                this.groupElements(response, this.groupBy, this.expectedResult).then(
                    (result) =>{
                        this.results = result;
                        if(this.template.querySelector('c-grouped-table')){
                            this.template.querySelector('c-grouped-table').resetPage();
                        }
                        this.loading = false;
                        this.showModal = true;
                    }
                )
            }).catch((errorMsg) => {
                this.loading = false;
                error(this, errorMsg.body.message);
            });
        } else {
            searchPoint({
                searchText : value,
                accountId : this.accountId,
                companyDivision : this.companyDivision,
                supplyStatus : this.supplyStatus
            }).then((response) => {
                this.queryResult = response;
                this.groupElements(response, this.groupBy, this.expectedResult).then(
                    (result) =>{
                        this.results = result;
                        if(this.template.querySelector('c-grouped-table')){
                            this.template.querySelector('c-grouped-table').resetPage();
                        }
                        this.loading = false;
                        this.showModal = true;
                    }
                )
            }).catch((errorMsg) => {
                this.loading = false;
                error(this, errorMsg.body.message);
            });
        }
    }

    async groupElements(elements, groupBy, expectedResult) {
        let promise = new Promise((resolve) => {
            setTimeout(() => resolve("done!"), 100);
        });
    
        await promise;
        let fromPoint = 'CurrentSupply__r.';

        let groupsObj = elements.reduce(function(objectsByKeyValue, item) {
            let path = groupBy.split('.');
            let value = path.reduce((obj, key) => ((obj && obj[key] !== 'undefined') ? obj[key] : undefined), item);
            let groupsByValue = {...objectsByKeyValue} || [];
            groupsByValue[value] = (groupsByValue[value] || []).concat(item);
            return groupsByValue;
        },{});

        let groups = [];
        for(let [key, value] of Object.entries(groupsObj)) {
            let row = {};
            row.key = key;
            row.selected = false;
            row.isGroup = true;
            
            let accountPath;
            let keyPath;
            if(groupBy.endsWith('ServiceSite__c')) {
                accountPath = 'ServiceSite__r.Account__r.Name';
                keyPath = 'ServiceSite__r.SiteAddress__c';
            } else if(groupBy.endsWith('ContractAccount__c')) {
                accountPath = 'ContractAccount__r.Account__r.Name';
                keyPath = 'ContractAccount__r.Name';
            } else {
                accountPath = 'Contract__r.Account.Name';
                keyPath = 'Contract__r.ContractNumber';
            }

            if(expectedResult === 'ServicePoint__c'){
                accountPath = fromPoint + accountPath;
                keyPath = fromPoint + keyPath;
            }
            row.data = accountPath.split('.').reduce((obj, k) => ((obj && obj[k] !== 'undefined') ? obj[k] : undefined), value[0]) + ' - ' +
                keyPath.split('.').reduce((obj, k) => ((obj && obj[k] !== 'undefined') ? obj[k] : undefined), value[0]);
            let children = [];
            for(let v of value){
                children.push({ key: v.Id, selected:false, isGroup: false, data: v})
            }
            row.children = children;
            groups.push(row);
        }
        
        return groups;
    }

    confirm() {
        if(this.multiSelection === false) {
            this.dispatchEvent(new CustomEvent('selected', { detail: {selected : this.selectedItems} }));
            this.showModal = false;
            this.resetBox();
            return;
        }
        //Multiselect enabled
        let selectedRows = [];
        for(let g of this.results) {
            for(let row of g.children) {
                if(row.selected){
                    selectedRows.push(row.data.Id);
                }
            }
        }
        this.dispatchEvent(new CustomEvent('selected', { detail: {selected : selectedRows} }));
        this.showModal = false;
        this.resetBox();
    }

    handleItemSelect(evt) {
        let detail = evt.detail;
        if(this.multiSelection === false) {
            this.selectedItems = [detail.key];
            return;
        }
        //multiselect enabled
        let group = this.results.filter(obj => {return obj.key === detail.groupKey})[0];
        let row = group.children.filter(obj => {return obj.key === detail.key})[0];
        row.selected = detail.selected;
        if(detail.selected === false){
            group.selected = false;
        }
    }

    handleGroupSelect(evt) {
        let detail = evt.detail;
        if(this.multiSelection === false) {
            return;
        }
        //multiselect enabled
        let group = this.results.filter(obj => {return obj.key === detail.groupKey})[0];
        group.selected = detail.selected;
        for(let r of group.children){
            if(detail.children.includes(r.key)) {
                r.selected = detail.selected;
            }
        }
    } */
}