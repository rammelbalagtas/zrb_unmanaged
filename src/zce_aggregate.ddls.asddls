@EndUserText.label: 'Test aggregation'
@ObjectModel.query.implementedBy:'ABAP:ZCE_AGGREGATE_DPC'
@UI.headerInfo: {
    typeName: 'Travel',
    typeNamePlural: 'Travel'
}

@UI.presentationVariant: [
  {
    qualifier: 'DefaultVariant',
    groupBy : [ 'Agency_ID', 'Customer_ID' ], 
    visualizations: [{type: #AS_LINEITEM, qualifier: 'DefaultVariant'}]
  }
]

@UI.chart: [{
    qualifier: 'Chart1',   //refers to targetQualifier defined in chart facet in Z_C_TRAVEL_UI
    title: 'Flight Prices of this Travel by Airline',
    chartType: #COMBINATION_DUAL,
    dimensions: [ 'Travel_ID'],
    measures: [ 'Total_Price'],
    measureAttributes: [ {measure: 'Total_Price', role: #AXIS_1}],
    dimensionAttributes: [ {dimension: 'Travel_ID', role: #SERIES} ],
    description: 'Chart shows flight prices of travel by the airlines used per each booking.'
    }
]

define root custom entity ZCE_AGGREGATE
{
      @UI.facet     : [{
         id         : 'Detail',
         purpose    : #STANDARD,
         position   : 10,
         label      : 'Travel Detail',
         type       : #IDENTIFICATION_REFERENCE
      }]

      @EndUserText.label: 'Travel ID'
      @UI           : { lineItem:    [ { position: 10, qualifier: 'DefaultVariant'} ],
                        identification: [ { position: 10 } ],
                        selectionField: [ { position: 10 } ] }
  key Travel_ID     : abap.numc( 8 );

      @EndUserText.label: 'Agency ID'
      @UI           : { lineItem:    [ { position: 20, qualifier: 'DefaultVariant' } ],
                        identification: [ { position: 20 } ],
                        selectionField: [ { position: 20 } ] }
      Agency_ID     : abap.numc( 6 );

      @EndUserText.label: 'Customer ID'
      @UI           : { lineItem:    [ { position: 30, qualifier: 'DefaultVariant' } ],
                        identification: [ { position: 30 } ],
                        selectionField: [ { position: 30 } ] }
      Customer_ID   : abap.numc( 6 );

      @EndUserText.label: 'Begin Date'
      @UI           : { lineItem:    [ { position: 40, qualifier: 'DefaultVariant' } ],
                        identification: [ { position: 40 } ],
                        selectionField: [ { position: 40 } ] }
      Begin_Date    : abap.dats;

      @EndUserText.label: 'End Date'
      @UI           : { lineItem:    [ { position: 50, qualifier: 'DefaultVariant' } ],
                        identification: [ { position: 50 } ],
                        selectionField: [ { position: 50 } ] }
      End_Date      : abap.dats;

      @EndUserText.label: 'Booking Fee'
      @Aggregation.default: #SUM
      @UI           : { lineItem:    [ { position: 60, qualifier: 'DefaultVariant' } ],
                        identification: [ { position: 60 } ]}
      Booking_Fee   : abap.dec( 17, 3 );

      @EndUserText.label: 'Total Price'
      @Aggregation.default: #SUM
      @UI           : { lineItem:    [ { position: 70, qualifier: 'DefaultVariant' } ],
                        identification: [ { position: 70 } ]}
      Total_Price   : abap.dec( 17, 3 );

      @EndUserText.label: 'Currency'
      @UI           : { lineItem:    [ { position: 80, qualifier: 'DefaultVariant' } ],
                        identification: [ { position: 80 } ]}
      Currency_Code : abap.cuky;

}
