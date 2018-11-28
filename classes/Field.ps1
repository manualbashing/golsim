class Field 
{
    [bool]$State
    [bool]$PredictedNextState
    [Field[]]$Neighbor
    
    Field([bool]$State)
    {
        $this.State = $State
        $this.PredictedNextState = $false
    }

    [Field[]]GetNeighbor()
    {
        return $this.Neighbor
    }
    
    [void]AddNeighbor([Field]$Field) 
    {
        if ($Field -notin $this.GetNeighbor()) 
        {
            $this.Neighbor += $Field    
        }
    }

    [void]RegisterNeighbor([Field]$Field)
    {
        if ($null -ne $Field) 
        {
            $Field.AddNeighbor($this)
            $this.AddNeighbor($Field)
        }
    }

    [int]GetAliveNeighborSum() 
    {
        $sum = $this.GetNeighbor() | 
            Measure-Object -Property State -Sum |
            Select-Object -ExpandProperty Sum
        return $sum
    }

    [void]UpdatePredictedNextState()
    {
        <#
            Rules for new state:

            - If a cell has less than two '1' neighbors, that cell becomes '0'
            - If a cell has exactly two '1' neighbors, that cell does not change
            - If a cell has exactly three '1' neighbors, that cell becomes '1'
            - If a cell has more than three neighbors, that cell becomes '0'
        #>

        switch ($this.GetAliveNeighborSum()) 
        {
            {$_ -lt 2 -or $_ -gt 3} { $this.PredictedNextState = $false }
            2 { $this.PredictedNextState = $this.State }
            3 { $this.PredictedNextState = $true }
            Default { }
        }
    }

    [void]NextState()
    {
        $this.State = $this.PredictedNextState
    }

    [void]SetState([bool]$State)
    {
        $this.State = $State
    }

    [string]ToString() 
    {
        $stateString = '  '
        if ($this.State) 
        {
            $stateString = '██'    
        }
        return $stateString
    }
}