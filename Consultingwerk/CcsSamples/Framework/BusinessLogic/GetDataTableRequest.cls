/*------------------------------------------------------------------------
    File        : IGetDataTableRequest
    Purpose     : Contains table specific request arguments of the
                  IGetDataRequest interface, part of the request object send
                  to the getData method of the IBusinessEntity
    Syntax      :
    Description :
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sun May 22 19:58:02 CEST 2016
    Notes       :
  ----------------------------------------------------------------------*/

USING Consultingwerk.CcsSamples.Framework.BusinessLogic.* FROM PROPATH.
USING Ccs.BusinessLogic.* FROM PROPATH .
USING Progress.Lang.*     FROM PROPATH .

CLASS Consultingwerk.CcsSamples.Framework.BusinessLogic.GetDataTableRequest
    IMPLEMENTS IGetDataTableRequest:

    /*------------------------------------------------------------------------------
        Purpose: Returns the paging context
        Notes:   Used for Paging. This value typically consists of record identifiers
                 (e.g. DATA-SOURCE ROWID retrieved by the RESTART-ROWID function of
                 the previous call into IBusinessEntity:GetData or other data required
                 by the Business Entity to build the next set of data).
                 The value passed in is the value of the NextPagingContext property
                 of the IGetDataTableResponse for the table
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY PagingContext AS CHARACTER NO-UNDO
    GET.
    SET.

    /*------------------------------------------------------------------------------
        Purpose: Returns the number of records requested by the caller or the
                 Business Entity GetData method
        Notes:   Used for Paging. When the value is 0, the business entity is expected
                 to return all (remaining) values. When the value is ? the business
                 entity is expected to return a reasonable default number of records
                 to the caller
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY NumRecords AS INT64 NO-UNDO
    GET.
    SET.

    /*------------------------------------------------------------------------------
        Purpose: Returns the abstract query defintion for this request
        Notes:   Typically used as an alternative to the QueryString
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY QueryDefinition AS IQueryDefinition NO-UNDO
    GET.
    SET.

    /*------------------------------------------------------------------------------
        Purpose: Returns the Query String for this table
        Notes:   Query Strings must be expressed using the fields of the temp-table.
                 Its the task of the Business Entity or Data Access class to translate
                 the Query String into the form understood by the actual DBMS in case
                 field names require mapping etc.
                 Query Strings may be provided in one of the following formats to allow
                 intuitive usage similar to the FIND-FIRST and QUERY-PREPARE methods
                 of the ABL buffer and query object handle:
                 CustNum = 42
                 CustNum = 42 AND OrderStatus = “Ordered”
                 WHERE CustNum = 42
                 WHERE CustNum = 42 AND OrderStatus = “Ordered”
                 FOR EACH eOrder WHERE eOrder.CustNum = 42
                 FOR EACH eOrder WHERE eOrder.CustNum = 42 AND eOrder.OrderStatus = “Ordered”
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY QueryString AS CHARACTER NO-UNDO
    GET.
    SET.

    /*------------------------------------------------------------------------------
        Purpose: Returns the number of records to skip
        Notes:   Used for Paging. Typically the value of (page# - 1) * NumRecords is
                 passed in when requesting a certain page of result records
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Skip AS INT64 NO-UNDO
    GET.
    SET.

    /*------------------------------------------------------------------------------
        Purpose: Returns the name of the ProDataset Table
        Notes:   Identifies the table this IGetDataTableRequest belongs to
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY TableName AS CHARACTER NO-UNDO
    GET.
    SET.

    /**
     * Purpose:
     * Notes:
     *
     */
    CONSTRUCTOR PUBLIC GetDataTableRequest ():
    END CONSTRUCTOR.

    /**
     * Purpose:
     * Notes:
     *
     */
    CONSTRUCTOR PUBLIC GetDataTableRequest (pcTableName AS CHARACTER,
                                            pcQueryString AS CHARACTER):

         ASSIGN THIS-OBJECT:TableName   = pcTableName
                THIS-OBJECT:QueryString = pcQueryString .

    END CONSTRUCTOR.

    /**
     * Purpose:
     * Notes:
     *
     */
    CONSTRUCTOR PUBLIC GetDataTableRequest (pcTableName AS CHARACTER,
                                            poQueryEntries AS IQueryEntry EXTENT):

         DEFINE VARIABLE oSort AS IQuerySortEntry EXTENT .

         ASSIGN THIS-OBJECT:TableName       = pcTableName
                THIS-OBJECT:QueryDefinition = NEW QueryDefinition (NEW QueryGroup(poQueryEntries), oSort) .

    END CONSTRUCTOR.

    /**
     * Purpose:
     * Notes:
     *
     */
    CONSTRUCTOR PUBLIC GetDataTableRequest (pcTableName AS CHARACTER,
                                            poQueryEntry AS IQueryEntry):

         DEFINE VARIABLE oSort AS IQuerySortEntry EXTENT .

         ASSIGN THIS-OBJECT:TableName       = pcTableName
                THIS-OBJECT:QueryDefinition = NEW QueryDefinition (poQueryEntry, oSort) .

    END CONSTRUCTOR.

END CLASS.
