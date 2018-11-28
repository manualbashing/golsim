class Game 
{
    [Grid]$Grid
    [int]$Iteration
    [int]$Delay
    

    Game ([int]$Height, [int]$Width, [bool]$Random, [int]$Iteration, [int]$Delay) 
    {
        $this.Grid = [Grid]::new($Height,$Width,$Random)
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