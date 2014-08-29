/**
 * Created with JetBrains RubyMine.
 * User: kenmcfadden
 * Date: 8/28/14
 * Time: 8:47 AM
 * To change this template use File | Settings | File Templates.
 */

jQuery(function ($) {

    $(document).on('click', '#btn_hit', function() {

        $.ajax({
            type: 'POST',
            url: '/form_player_hit'
        }).done(function(response) {
                $('#game_page').replaceWith(response);
            });
        return false;
    });


    $(document).on('click', '#btn_stand', function() {

        $.ajax({
            type: 'POST',
            url: '/form_player_stand'
        }).done(function(response) {
                $('#game_page').replaceWith(response);
            });
        return false;
    });


    $(document).on('click', '#btn_dealer', function() {

        $.ajax({
            type: 'POST',
            url: '/form_dealer_button'
        }).done(function(response) {
                $('#game_page').replaceWith(response);
            });
        return false;
    });

    $(document).on('click', '#btn_quit', function() {

        $.ajax({
            type: 'POST',
            url: '/form_player_quit'
        }).done(function(response) {
                $('#game_page').replaceWith(response);
            });
        return false;
    });


});
