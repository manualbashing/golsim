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
        $stateString = ' '
        if ($this.State) 
        {
            $stateString = 'X'    
        }
        return $stateString
    }
}

class Grid 
{
    [Field[]]$Fields
    [int]$Height
    [int]$Width
    [String]$Init

    [void]_initFields()
    {
        $previousRow = @()
        for ($i = 0; $i -lt $this.Height; $i++) 
        {
            $currentRow = @()
            for ($j = 0; $j -lt $this.Width; $j++) 
            {
                $state = $false
                if ($this.Random) 
                {
                    $state = Get-Random -Minimum 0 -Maximum 2    
                }
                $currentField = [Field]::New($state)
                $currentField.RegisterNeighbor($previousRow[$j]) # North
                $currentField.RegisterNeighbor($previousRow[$j+1]) # NorthEast
                $currentField.RegisterNeighbor($previousRow[$j-1]) # NorthWest
                $currentField.RegisterNeighbor($currentRow[$j-1]) # West
                $currentRow += $currentField
                $this.Fields += $currentField
            }
            $previousRow = $currentRow
        }
    }

    [string]_convertFromRLE($RLE) 
    {
        $pattern = '(?<count>[0-9]+)(?<cell>b|o)'
        $RleArray = $RLE -replace $pattern,'!$1$2!' -split '!'
        
        for ($i = 0; $i -lt $RleArray.Length; $i++)
        { 
            if($RleArray[$i] -match $pattern)
            {
                $RleArray[$i] = $Matches['cell']*$Matches['count']
            }
        }
        $RleArray = $RleArray -join '' -split '\$'
        
        for ($i = 0; $i -lt $RleArray.Length; $i++)
        { 
            $RleArray[$i] = $RleArray[$i].PadRight($this.Width,' ')
            $RleArray[$i] = $RleArray[$i] -replace 'b', ' ' -replace 'o','X'
        }
        return $RleArray -join ''
    }
    
    Grid([string]$Path)
    {
        $inputGrid = Get-Content -Path $Path
        $this.Height = $inputGrid.Length
        $this.Width = $inputGrid[0].Length
        $inputGrid = $inputGrid -join '' -as [char[]]
        $this._initFields()
        for ($i = 0; $i -lt $this.Fields.Count; $i++) 
        {
            $state = $inputGrid[$i] -ne ' '
            $this.Fields[$i].SetState($state)     
        }
    }
    
    Grid([int]$Height, [int]$Width, [bool]$Random)
    {
        $this.Height = $Height
        $this.Width = $Width
        $this.Random = $Random
        $this._initFields()
    }

    Grid([int]$Height,[int]$Width,[String]$RLE)
    {
        # x = 3, y = 3
        # $RLE = bo$2bo$3o!
        $this.Height = $Height
        $this.Width = $Width
        $this._initFields()
        $inputGrid = $this._convertFromRLE($RLE)
        for ($i = 0; $i -lt $inputGrid.Length; $i++) 
        {
            $state = $inputGrid[$i] -ne ' '
            $this.Fields[$i].SetState($state)
        }
    }

    [void]NextState()
    {
        foreach ($field in $this.Fields)
        {
            $field.UpdatePredictedNextState()
        }
        foreach ($field in $this.Fields)
        {
            $field.NextState()
        }
    }

    [string]ToString() 
    {
        $output = ''
        $row = ''
        for ($i = 0; $i -lt $this.Fields.Count; $i++) 
        {
            $row += $this.Fields[$i].ToString()
            if (($i+1) % $this.Width -eq 0) 
            {
                $output += ($row + "`n")
                $row = ''
            }   
        }
        return $output
    }
}

class Game 
{
    [Grid]$Grid
    [int]$Iteration
    [int]$Delay
    

    Game ([int]$Height, [int]$Width, [int]$Iteration, [int]$Delay) 
    {
        $this.Grid = [Grid]::new($Height,$Width)
        $this.Iteration = $Iteration
        $this.Delay = $Delay
    }

    Game ([int]$Height, [int]$Width, [String]$RLE, [int]$Iteration, [int]$Delay) 
    {
        $this.Grid = [Grid]::new($Height,$Width,$RLE)
        $this.Iteration = $Iteration
        $this.Delay = $Delay
    }

    Game ([string]$Path, [int]$Iteration, [int]$Delay) 
    {
        $this.Grid = [Grid]::new($Path)
        $this.Iteration = $Iteration
        $this.Delay = $Delay
    }

    StartGame()
    {
        Clear-Host
        Write-Host "Iteration: "
        Write-Host $this.Grid.ToString()
        
        for ($i = 1; $i -le $this.Iteration; $i++) 
        {
            $this.Grid.NextState()
            Clear-Host
            Write-Host "Iteration: $i"
            Write-Host $this.Grid.ToString()
            Start-Sleep -Milliseconds $this.Delay
        }
    }
}