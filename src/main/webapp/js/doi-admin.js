$(document).ready(function() {

    $('#doi-admin-table').DataTable({
        "aLengthMenu": [[5, 10, 50, -1], [5, 10, 50, "All"]],

        "bProcessing": true,
        "bDeferRender": true
    });
    $('#doi-admin-table-loading').hide();
    $('#doi-admin-table').show();

    $(".clickable-row").click(function() {
        window.document.location = $(this).data('url');
    });

});