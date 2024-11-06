// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITRC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
}

interface IRouter {
    function addLiquidityTRX(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    
    function swapExactTRXForTokens(
        uint amountOutMin, 
        address[] calldata path,
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function WTRX() external returns (address);

}

interface IWTRX {
    function deposit() external payable;
    function withdraw(uint amount) external;
}

contract TokenLaunchpad {
    address public owner;
    IRouter public router;
    IWTRX public wtrx;

    constructor(address _router, address _wtrx) {
        owner = msg.sender;
        router = IRouter(_router);
        wtrx = IWTRX(_wtrx);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Struct to group liquidity-related parameters
    struct LiquidityParams {
        address token;
        uint amountTokenDesired;
        uint amountTokenMin;
        uint amountETHMin;
        address to;
        uint deadline;
    }

    // Struct to group swap-related parameters
    struct SwapParams {
        uint amountInForSwap;
        uint amountOutMin;
        address[] pathForSwap;
        uint deadline;
    }

    // Event to debug liquidity addition
    event LiquidityAdded(
        uint amountToken,
        uint amountETH,
        uint liquidity,
        address indexed to
    );

    // Event to debug token swap
    event TokenSwapped(
        uint[] amounts,
        address[] path,
        address indexed to
    );

    // Event to log token withdrawal
    event TokensWithdrawn(address token, uint amount);

    // Event to log TRX withdrawal
    event TRXWithdrawn(uint amount);

    // Function to handle both addLiquidity and swapExactTokensForTokens, with TRX handling
    function addLiquidityAndBuyToken(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        uint liquidityTrxAmount,
        uint buyTrxAmount
    ) external payable onlyOwner {

        ITRC20 tokenContract = ITRC20(token);
        require(tokenContract.balanceOf(address(this)) >= amountTokenDesired, "Insufficient token balance");

        // Approve the router to spend the contract's tokens if needed
        if (tokenContract.allowance(address(this), address(router)) < amountTokenDesired) {
            require(
                tokenContract.approve(address(router), amountTokenDesired),
                "Token approval for router failed"
            );
        }

        // Add liquidity and capture return values
        {
            (uint amountToken, uint amountETH, uint liquidity) = router.addLiquidityTRX{value: liquidityTrxAmount}(
                token,
                amountTokenDesired,
                amountTokenMin,
                amountETHMin,
                to,
                deadline
            );

            require(liquidity > 0, "Liquidity addition failed");

            // Emit event for debugging liquidity addition
            emit LiquidityAdded(amountToken, amountETH, liquidity, to);
        }

        // Swap tokens and handle failure
        
        address[] memory path = new address[](2);
        path[0] = router.WTRX();  // WTRX (Wrapped TRX) address
        path[1] = token;
        {
            uint[] memory amounts = router.swapExactTRXForTokens{value: buyTrxAmount}(
                0,
                path,
                to,
                deadline
            );
            require(amounts[amounts.length - 1] >= 0, "Swap output too low");

            // Emit event for debugging token swap
            emit TokenSwapped(amounts, path, to);
        }
    }


    function tokenBalanceOf(address token) public view returns (uint amount){
        ITRC20 tokenContract = ITRC20(token);
        
        uint ret = tokenContract.balanceOf(address(this));
        return ret;
    }

    function depositToken (address token, uint amount) external {
        ITRC20 tokenContract = ITRC20(token);

        require(tokenContract.balanceOf(msg.sender) >= amount, "Insufficient Tokens in Sender");

        tokenContract.transferFrom(msg.sender, address(this), amount);
    }

    // Function to withdraw tokens
    function withdrawTokens(address token, uint amount) external onlyOwner {
        require(ITRC20(token).balanceOf(address(this)) >= amount, "Insufficient token balance");
        require(ITRC20(token).transfer(owner, amount), "Token withdrawal failed");

        // Emit event for token withdrawal
        emit TokensWithdrawn(token, amount);
    }

    // Function to withdraw TRX
    function withdrawTRX(uint amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient TRX balance");
        wtrx.withdraw(amount);
        payable(owner).transfer(amount);

        // Emit event for TRX withdrawal
        emit TRXWithdrawn(amount);
    }

    // Allow the contract to receive TRX
    receive() external payable {}
}
