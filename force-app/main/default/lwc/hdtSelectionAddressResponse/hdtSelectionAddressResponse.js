import { LightningElement, api, track } from 'lwc';
export default class HdtSelectionAddressResponse extends LightningElement {

    @api objectapiname;
    @api accountid;
    @api theRecord;
    disableCheckBoxComune=false;
    @api previsionecomune;
    @api prevcap;
    @api prevvia ;
    @api prevprovincia ;
    @api listobjtoshow ;
    @api headertoshow ;
    @api filterinputword ; 
    @api filterinputword2 ; 
    tableColumnsComune=[];
    columnsComune = [
        { label: 'Città', fieldName: 'city1', type: 'text' },
        { label: 'Codice Comune SAP', fieldName: 'cityCode', type: 'text' },
        { label: 'Provincia', fieldName: 'region', type: 'text' }
    ];
    columnsIndirizzo = [
        { label: 'Via', fieldName: 'street', type: 'text' },
        { label: 'Codice Via SAP', fieldName: 'streetCode', type: 'text' }
    ];
    columnsComp = [
        { label: 'Città', fieldName: 'city1', type: 'text' }
    ];
    tableDataComune=[];
    @api tableoriginaldata=[];
    pages = [];
    columns = [];
    originalData = [];
    //currentPage
    @track currentPage = 1;
    
    totalPage = 0;
    preloading = false;
    confirmButtonDisabled=true;
    prevrowtosend=[];
    @track submitedAddressFields = {};
    @api prevwrapaddressobject ;
    @track openForm=false;
    @track openForm2=false;

    mapComune= [
		{
			"Città" : "RAVENNA",
			"Codice Comune SAP" : "39014",
			"Provincia" : "RA"
		},
		{
			"Città" : "RAVELLO",
			"Codice Comune SAP" : "65104",
			"Provincia" : "SA"
		}
	];

    mapComuneRavel= [
		{
			"Città" : "RAVELLO",
			"Codice Comune SAP" : "65104",
			"Provincia" : "SA"
		}
	];

    mapComuneRaven= [
		{
			"Città" : "RAVENNA",
			"Codice Comune SAP" : "39014",
			"Provincia" : "RA"
		}
	];

    mapVia=  [
		{
			"Cod Stradario SAP" : "39014000478",
			"Via" : "CARRAIA FIUME"
		},
		{
			"Cod Stradario SAP" : "39014002078",
			"Via" : "CARRACCI ANNIBALE"
		}
	]
;
mapViaCarraia=  [
    {
        "Cod Stradario SAP" : "39014000478",
        "Via" : "CARRAIA FIUME"
    }
];

mapViaCarracci=  [
    {
        "Cod. Stradario SAP" : "39014002078",
        "Via" : "CARRACCI ANNIBALE"
    }
];


 @api
    closeForm(){
        this.openForm=false;
        this.openForm2=false;
    }

@api
    openedForm(){
        console.log('entra in openedForm');
        this.openForm=true;
        this.currentPage = 1;
    }
    @api
    openedForm2(){
        
        this.openForm2=true;
        this.currentPage = 1;
    }
    get getCurrentPage() {
        if (this.totalPage===0) return 0;
        return this.currentPage;
    }
    @api
    nextPage2() {
        if (this.currentPage < this.totalPage)
        {this.currentPage++;
            this.reLoadTableComune();
        }
    }
    @api
    previousPage2() {
        console.log("+non faccio niente");
        if (this.currentPage > 1) {
            this.currentPage--;
            this.reLoadTableComune();
        }
    }
    handleChnage(event) {
        console.log('rowtosend*****' + JSON.stringify(this.prevrowtosend));
        //this.getSelectedComune(event);
        //this.previsionecomune=this.prevrowtosend['city1'];
        console.log('rowtosend*****' + JSON.stringify(this.prevrowtosend));
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("selectedvalue", {
            detail: event.detail.selectedRows[0]
          });
    
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
      }
 /**
     * Create header for Data-Table header with original data
     */
  formatTableHeaderColumns(rowData) {
    let columns = [];
    this.tableColumnsComune = [];
    rowData.forEach(row => {
        let keys = Object.keys(row);
        columns = columns.concat(keys);
    });
    let columnsUniq = [...new Set(columns)];
    columnsUniq.forEach(field => this.tableColumnsComune.push({label: field, fieldName: field}));
}

/**
     * Create Data-Table
     */
 createTable(data) {
    let i, j, temporary, chunk = 10;
    this.pages = [];
    for (i = 0, j = data.length; i < j; i += chunk) {
        temporary = data.slice(i, i + chunk);
        this.pages.push(temporary);
    }
    this.totalPage = this.pages.length;
    this.reLoadTableComune();
}
handleFilterDataTable(event) {
    let val = event.target.value;
        let self = this;
        let data;
        setTimeout(function () {
            data = JSON.parse(JSON.stringify(self.listobjtoshow));
            console.log("************:@@@@@@:" + JSON.stringify(data));
            if (val.trim() !== '') {
                data = data.filter(row => {
                    let found = false;
                    console.log("********ROW:" + row);
                    Object.values(row).forEach(v => {
                        if (v !== undefined && null != v.toLowerCase() && (v.toLowerCase().search(val.toLowerCase())  !== -1 ) ) {
                            found = true;
                        }
                    });
                    if (found) return row;
                })
            }
            self.createTable(data); // redesign table
            self.currentPage = 1; // reset page
        }, 1000);
}

reLoadTableComune() {
   // this.tableDataComune = [];
    this.tableDataComune = this.pages[this.currentPage - 1];

    console.log('tableData********'+ JSON.stringify(this.tableDataComune));

}


reLoadTable() {
    this.tableDataComune = this.pages[this.currentPage];

    console.log('tableData********'+ JSON.stringify(this.tableDataComune));

}

getSelectedComune(event){
    console.log('getSelectedComune START');
    this.disableCheckBoxComune=true;
    this.preloading = true;
    let selectedRows = event.detail.selectedRows;
    this.confirmButtonDisabled = (selectedRows === undefined || selectedRows.length == 0) ? true : false;
    this.prevrowtosend = (selectedRows[0] !== undefined) ? selectedRows[0]: {};
    console.log('rowToSend ******' + JSON.stringify(this.prevrowtosend['city1']));
    this.preloading = false;
    console.log('getSelectedComune END');
}

@api
    connectedCallback(event){
        
 
        console.log('connectedCallback START');
        console.log('connectedCallback listobjtoshow ' + JSON.stringify(this.listobjtoshow));
        if(this.headertoshow = 'Comune'){
            //this.columns = this.columnsComune;
            this.openForm=true;
        }
        else if(this.headertoshow = 'Via'){
            //this.columns = this.columnsIndirizzo;
            this.openForm=false;
            this.openForm2=true;
        }
        this.currentPage = 1;
        this.createTable(this.listobjtoshow);
        // this.tableDataComune = this.listobjtoshow;
        console.log("*********:"+JSON.stringify(this.listobjtoshow));

        console.log('connectedCallback END');

    }

    @api
    valorizeTable(data,headerTab){
        
        //Object.keys(this.prevwrapaddressobject[0]).forEach(key=>{
        //    console.log('key*********************************' + key);
            //this.createTable(this.listObjtoShow);
            this.createTable(data);
            if(headerTab = 'Comune'){
                
                this.openForm=false;
                this.openForm=true;
            }
            else{
                this.openForm = false;
                this.openForm2=false;
                this.openForm2=true;
            }
            
            console.log("*********:"+JSON.stringify(data));
            console.log("*********:"+JSON.stringify(this.tableDataComune));
            
            //this.formatTableHeaderColumns(this.listObjtoShow);
            /*switch(key){
                case 'fieldname':
                    /*if(this.previsionecomune==='RAVEN'){
                        this.createTable(this.mapComuneRaven);
                        this.formatTableHeaderColumns(this.mapComuneRaven);
                    }else if(this.previsionecomune==='RAVEL'){
                        this.createTable(this.mapComuneRavel);
                        this.formatTableHeaderColumns(this.mapComuneRavel);
                    }else{
                        this.createTable(this.mapComune);
                        this.formatTableHeaderColumns(this.mapComune);
                    }*/
                    /*if(this.prevvia==='CARRAI'){
                        this.createTable(this.mapViaCarraia);
                        this.formatTableHeaderColumns(this.mapViaCarraia);
                    }
                    else if(this.prevvia==='CARRAC'){
                        this.createTable(this.mapViaCarracci);
                        this.formatTableHeaderColumns(this.mapViaCarracci);
                    }else if(this.prevvia!=undefined||this.prevvia!=null){
                        this.createTable(this.mapVia);
                        this.formatTableHeaderColumns(this.mapVia);
                    }
                break;
                }*/

        //});
        console.log('HdtSelectionAddressResponse - START - prevwrapaddressobject : '+ JSON.stringify(this.prevwrapaddressobject));
        console.log('Comune**************' + JSON.stringify(this.previsionecomune));
        console.log('provincia**************' + JSON.stringify(this.prevprovincia));
        console.log('cap**************' + JSON.stringify(this.prevcap));
 
        /*
        */
        this.previsionecomune='';
        this.prevvia='';

            
    }

}