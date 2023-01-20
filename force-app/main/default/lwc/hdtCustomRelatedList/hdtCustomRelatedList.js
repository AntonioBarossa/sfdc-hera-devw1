import { LightningElement, api } from 'lwc';
import getRecordsToDisplay from "@salesforce/apex/HDT_LC_CustomRelatedList.getRecordsToDisplay";
import viewAll from '@salesforce/label/c.ViewAll';

export default class HdtCustomRelatedList extends LightningElement {

    @api recordId;
    @api childObjectApiName;
    @api childLookupField;
    @api fieldsToRetrieve;
    @api nameField = 'Name';
    @api linesToDisplay;
    retrieveAll = false;
    limitDisplayedLines = true;
    calculateTitle = true;

    labels = {
        viewAll: viewAll,
    };

    title = '';
    fetchColumns = true;
    relationshipFields = '';

    // dataTable variables
    columns = {};
    data;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy = '';

    connectedCallback() {

        // console.log(this.recordId, this.childObjectApiName, this.childLookupField, this.fieldsToRetrieve, this.linesToDisplay);

        getRecordsToDisplay ({ parentRecordId: this.recordId, 
                               childObjectApiName: this.childObjectApiName, 
                               childLookupField: this.childLookupField,
                               fieldsToRetrieve: this.fetchColumns ? this.fieldsToRetrieve : (this.fieldsToRetrieve + this.relationshipFields),
                               nameField: this.nameField,
                               retrieveAll: this.retrieveAll,
                               fetchColumns: this.fetchColumns
                            }).then(result => {
            
            if(result) {
                if (this.calculateTitle) this.title = result.objectLabel + ' (' + (result['childRecords'].length > 6 ? '6+' : result['childRecords'].length) + ')';
                this.generateDataTable(result['columns'], result['childRecords'], this.fetchColumns ? result['relationshipsAddedToQuery'] : this.relationshipFields);

                // this.columns = [{
                //     label: 'Opportunity name',
                //     fieldName: 'nameUrl',
                //     type: 'url',
                //     typeAttributes: {label: { fieldName: 'name' }, 
                //     target: '_self'},
                //     sortable: true
                // }];

                // this.data = [
                //     { Id: 1, nameUrl: '/0011X00000iFRsMQAW', name: 'ciao' },
                //     { Id: 2, nameUrl: '/0011X00000iFRsMQAW', name: 'ciao1' },
                //     { Id: 3, nameUrl: '/0011X00000iFRsMQAW', name: 'ciao2'}
                // ];

            }

        });


    }

    generateDataTable(columns, retrievedData, relationshipFields) {

        let i = 0;

        this.data = new Array();
        this.columns = columns ? JSON.parse(columns) : this.columns;
        this.relationshipFields = relationshipFields;

        // console.log(columns);

        retrievedData.every(record => {

            let tableRow = '{'

            tableRow += '"Id": ' + i;

            // console.log('record', record);

            (this.fieldsToRetrieve + relationshipFields).split(',').forEach(field => {

                let value;

                if(field.includes('.')) {

                    // console.log('there is a relationship', field);
                    // console.log('split relationship', field.split('.'));

                    let splitRelationship = field.split('.');

                    value = record[splitRelationship[0]] ? record[splitRelationship[0]][splitRelationship[1]] : '';

                } else {

                    value = (field.toUpperCase() === 'ID' || (relationshipFields.includes(field) && record[field]) ? '/' : '') + record[field];

                    if (relationshipFields.includes(field) && !record[field]) {
                        value = '/.';
                    }

                }

                tableRow += ', "' + field + '": "' + value + '"';

            });

            if (!this.fieldsToRetrieve.includes(',' + this.nameField + ',')) {
                tableRow += ', "' + this.nameField + '": "' + record[this.nameField] + '"';
            }

            // tableRow += ', "nameUrl": "test' + i + '"';
            tableRow += '}';

            // console.log(tableRow);

            this.data.push(JSON.parse(tableRow));

            i++;

            if (this.limitDisplayedLines && this.linesToDisplay && i == this.linesToDisplay) { 
                
                return false;

            } else {

                return true;

            }

        });

        this.sortedBy = this.fieldsToRetrieve.split(',')[0];
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {

        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        let customSortedBy = sortedBy;

        this.columns.every(element => {

            if (element.fieldName == sortedBy && element.type == 'url') {

                customSortedBy = element.typeAttributes.label.fieldName;
                return false;

            }

            return true;
        });

        cloneData.sort(this.sortBy(customSortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    refreshList() {
        this.fetchColumns = false;
        this.connectedCallback();
    }

    handleViewAll(event) {

        // console.log('view all');

        this.retrieveAll = true;
        this.fetchColumns = false;
        this.limitDisplayedLines = false;
        this.calculateTitle = false;

        this.title = this.title.slice(0, this.title.indexOf('('));

        this.connectedCallback();
        
    }

}