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