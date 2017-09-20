var SWFAddress = new function() {
    this.getValue = function()
    {
        return window.location.href;
    }

    this.href = function(url, target) {
        target = typeof target != UNDEFINED ? target : '_self';     
        if (target == '_self')
            self.location.href = url; 
        else if (target == '_top')
            window.href = url; 
        else
            window.open(url); 
    };
}
